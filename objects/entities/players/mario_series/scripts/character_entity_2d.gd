@icon("res://icons/character_entity_2d.svg")
class_name CharacterEntity2D extends Classes.HiddenEntityBody2D

## Basic class of Super Mario Systemed characters.
##
## [b]Note 1:[/b] If you have characters out of Super Mario Series implemented, this class will transform some of their
## behaviors to mario style, like getting hurt and death.[br]
## [b]Note 2:[/b] If the character contains a valid [CharacterBehavior2D] component, the component will override
## the [member EntityBody2D.gravity] and [member EntityBody2D.max_falling_speed] with [member CharacterBehavior2D.gravity]
## and [member CharacterBehavior2D.max_falling_speed]. Please pay close attention to this note if you are going to modify
## the gravity and max falling speed of the character.

signal hurt ## Emitted when the character gets damaged
signal died ## Emitted when the character is dead

## Warping directions, if not [code]NONE[/code], the player is not on warping, otherwise it is.[br]
## This is used to assign warping animations.
enum WarpDir {
	NONE = 0, ## Not warping
	UP = -1, ## Warping animation - jump
	DOWN = 1, ## Warping animation - crouch
	LEFT = -2, ## Warping animation - walking left
	RIGHT = 2 ## Warping animation - walking right
}

@export_category("Character")
@export_group("Death")
## [PackedScene] of the death of the character
@export var death: PackedScene = preload("res://objects/entities/players/mario_series/#death/mario_death.tscn")
@export_group("Core Info")
## Id of the character. Different ID will register different players
@export_range(0, 3, 1, "suffix:No.") var id: int
## Nickname of the character
@export var nickname: StringName = &"Player"
@export_group("Power")
## ID of current power's id[br]
## [br]
## [b]Note:[/b] Changing this will trigger the call of [method set_power_id]
@export var power_id: StringName = &"small":
	set = set_power_id
## If [code]true[/code], the power will not play appearing animation when it appears.[br]
## [br]
## [b]Note 1:[/b] Please keep this property open in the editor![br]
## [b]Note 2:[/b] If you need to change to a power without appearing animation, please turn this off before calling [method set_power_id]
@export var power_disable_appear: bool = true
@export_group("State Controls")
## If [code]true[/code], the character is controllable; otherwise it's uncontrollable.
@export var controllable: bool = true
@export_group("Physics")
## Direction of the character. This will effect the walking movement of him.
@export_enum("Left: -1", "Right: 1") var direction: int = 1:
	set(value):
		await Process.await_readiness(self)
		direction = value if value != 0 else [-1, 1].pick_random()

#region RefNodes
@onready var _flagger := get_flagger() as Flagger
@onready var _shape := get_collision_shape() as CollisionShape2D
@onready var _body_shape := $AreaBody/CollisionShape2D as CollisionShape2D
@onready var _head_shape := $AreaHead/CollisionPolygon2D as CollisionPolygon2D
@onready var _health_component := $HealthComponent as HealthComponent
#endregion

#region == Data ==
var _warp_dir: WarpDir = WarpDir.NONE # Warping direction
var _key_xy: Vector2i # Direction of arrow keys 
#endregion

#region == References ==
var _invulnerability: SceneTreeTimer # Reference to a invulnerability counter
var _power: CharacterPower2D # Reference to current power
#endregion


func _ready() -> void:
	# Registers the character
	var cmdl := CharactersManager2D.get_characters_data_list()
	cmdl.register(self)
	# Registers the power
	power_id = cmdl.get_data(id).get_power_id() # This will automatically call set_power_id()


#region == Health controls ==
## Makes the character invulnerable for [param duration] seconds.
func invulnerablize(duration: float = 2) -> void:
	if _flagger.is_flag(&"uninvulerizable"):
		return
	_invulnerability = get_tree().create_timer(duration, false)
	_invulnerability.timeout.connect(
		func() -> void:
			_invulnerability = null
	)

## Makes the character hurt with [signal hurt] emitted.
func damaged(tag: TagsObject = TagsObject.new()) -> void:
	if _flagger.is_flag(&"undamagible") || (!tag.get_tag(&"forced", false) && is_invulnerable()):
		return
	
	var soundful := tag.get_tag(&"soundful", true) as bool # Allowed to play the sound
	var duration := tag.get_tag(&"duration", 2) as float
	
	# Damaged to death
	Effects2D.flash(self, duration, 0.05)
	if _power.power_down_to_id.is_empty():
		_health_component.sub_health(tag.get_tag(&"damage", 1) as float)
		if _health_component.health <= 0: # No hp -> death
			die(tag)
			return
		else: # With hp -> hp loss
			invulnerablize(duration + 1)
	# Damaged to lower level of suit
	else:
		var forced_down_to_id := tag.get_tag(&"forced_down_to", &"small") as StringName
		power_id = forced_down_to_id if !forced_down_to_id.is_empty() else _power.power_down_to_id
		invulnerablize(duration)
	
	# Plays sound
	if soundful:
		Sound.play_sound_2d(self, _power.sound_hurt) 

## Makes the character die with [signal died] emitted.
func die(_tag: TagsObject = TagsObject.new()) -> void:
	if _flagger.is_flag(&"undyable"):
		return
	
	CharactersManager2D.get_characters_data_list().unregister(id)
	
	# Death
	if death:
		var death_ins := death.instantiate() # Create death instance
		var death_2d := death_ins as Node2D # Reference as Node2D to the death instance
		death_2d.global_transform = global_transform
		death_2d.visible = visible
		death_2d.sound_death = _power.sound_death
		add_sibling(death_2d)
		queue_free()
	else:
		print("[Character Death Error] No death effect for %s" % [name + str(get_instance_id())])

## Returns [code]true[/code] if the character is invulnerable.
func is_invulnerable() -> bool:
	return _invulnerability != null
#endregion

#region == Power ==
## Sets the power id of the character and put the power into application, if possible.
func set_power_id(value: StringName) -> void:
	if !is_node_ready():
		power_id = value
		return
	
	var power_ext: bool = false # Is power existing
	for i: Node in get_children():
		if !i is CharacterPower2D:
			continue
		
		i = i as CharacterPower2D
		if i.power_id == value: # Matched power
			power_ext = true
			_power = i
			
			i.process_mode = process_mode # Enables the power
			i.visible = visible
			
			if power_disable_appear:
				power_disable_appear = false
			else:
				i.appear()
			
			i.power_current.emit() # Called when the suit is current
		else: # Mismatched power
			i.visible = false
			i.process_mode = PROCESS_MODE_DISABLED
			i.power_current.emit() # Called when the suit is NOT current
	
	# Set the value if the power exists, or send an error if not
	if power_ext:
		power_id = value
	else:
		_power = null
		power_id = &""
		printerr("Invalid power id: %s. Please check if the power with such id exists or if the spelling is incorrect." % value)

## Returns current [CharacterPower2D].
func get_power() -> CharacterPower2D:
	return _power
#endregion

#region == Warping direction ==
## Sets the warping direction, and also controls [member controllable].
func set_warp_direction(to: WarpDir, controllable_control: bool = true) -> void:
	_warp_dir = to
	if controllable_control:
		controllable =  _warp_dir != WarpDir.NONE

## Returns current warping direction.
func get_warp_direction() -> WarpDir:
	return _warp_dir
#endregion

#region == Key actions ==
## Sets the direction of the arrow keys.
func set_key_xy(up: StringName, down: StringName, left: StringName, right: StringName) -> void:
	_key_xy = Vector2i(Input.get_vector(left + str(id), right + str(id), up + str(id), down + str(id)).round())

## Returns the direction of the arrow keys.
func get_key_xy() -> Vector2i:
	return _key_xy

## Returns the left(-1)/right(1) of the arrow keys.
func get_key_x() -> int:
	return _key_xy.x

## Returns the up(-1)/down(1) of the arrow keys.
func get_key_y() -> int:
	return _key_xy.y

## Same as [method Input.is_action_pressed], but the character's id is in consideration.
func is_action_pressed(action: StringName) -> bool:
	return Input.is_action_pressed(action + str(id))

## Same as [method Input.is_action_just_pressed], but the character's id is in consideration.
func is_action_just_pressed(action: StringName) -> bool:
	return Input.is_action_just_pressed(action + str(id))

## Same as [method Input.is_action_just_released], but the character's id is in consideration.
func is_action_just_released(action: StringName) -> bool:
	return Input.is_action_just_released(action + str(id))
#endregion

#region == Collision shapes ==
## Updates the scale and position of the character's collision shape and the one of its detector.
func update_body_collision_shapes(character_shape: CharacterShape2D) -> void:
	if _shape.shape != character_shape.shape:
		_shape.set_deferred(&"shape", character_shape.shape)
	if _body_shape.shape != character_shape.shape:
		_body_shape.set_deferred(&"shape", character_shape.shape)
	_shape.transform = character_shape.transform
	_body_shape.transform = character_shape.transform

## Updates the scale and position of the collision shape of the character's head detector.
func update_head_collision_shape(character_shape: CharacterShape2D) -> void:
	_head_shape.transform = character_shape.transform

## Returns the collision shape of the character.
func get_collision_shape() -> CollisionShape2D:
	return $CollisionShape2D

## Returns the body detector of the character.
func get_detector_body() -> Area2D:
	return $AreaBody

## Returns the head detector of the character.
func get_detector_head() -> Area2D:
	return $AreaHead
#endregion

## Returns the flagger
func get_flagger() -> Flagger:
	return $Flagger
