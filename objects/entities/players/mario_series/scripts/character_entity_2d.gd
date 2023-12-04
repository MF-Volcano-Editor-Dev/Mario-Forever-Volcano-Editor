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

const STATE_UNCONTROLLABLE := &"uncontrollable" ## Identifierized access to state "uncontrollable"
const STATE_UNDAMAGIBLE := &"undamagible" ## Identifierized access to state "undamagible"
const STATE_UNDYABLE := &"undyable" ## Identifierized access to state "undyable"
const STATE_UNINVUNERIZABLE := &"uninvulnerizable" ## Identifierized access to state "uninvulnerizable"

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
		direction = value if value != 0 else [-1, 1].pick_random()

#region RefNodes
@onready var shape := $CollisionShape2D as CollisionShape2D
@onready var body := $AreaBody as Area2D
@onready var body_shape := $AreaBody/CollisionShape2D as CollisionShape2D
@onready var head := $AreaHead as Area2D
@onready var head_shape := $AreaHead/CollisionPolygon2D as CollisionPolygon2D
@onready var health_component := $HealthComponent as HealthComponent
#endregion

#region == Data ==
var _warp_dir: WarpDir = WarpDir.NONE # Warping direction
#endregion

#region == References ==
var _invulnerability: SceneTreeTimer # Reference to a invulnerability counter
var _power: CharacterPower2D # Reference to current power
var _behavior: CharacterBehavior2D # Reference to a CharacterBehavior2D
#endregion


func _ready() -> void:
	# Registers the character
	var cmdl := CharactersManager2D.get_characters_data_list()
	cmdl.register(self)
	
	# Registers the power
	power_id = cmdl.get_data(id).get_power_id() # This will automatically call set_power_id()


#region == Health controls ==
## Makes the character invulnerable for [param duration] seconds
func invulnerablize(duration: float = 2) -> void:
	_invulnerability = get_tree().create_timer(duration, false)
	_invulnerability.timeout.connect(
		func() -> void:
			_invulnerability = null
	)

## Makes the character hurt with [signal hurt] emitted
func damaged(tag: TagsObject = TagsObject.new()) -> void:
	if ObjectState.is_state(self, STATE_UNDAMAGIBLE) || (!tag.get_tag(&"forced", false) && is_invulnerable()):
		return
	
	var soundful := tag.get_tag(&"soundful", true) as bool # Allowed to play the sound
	var duration := tag.get_tag(&"duration", 2) as float
	
	# Damaged to death
	Effects2D.flash(self, duration, 0.05)
	if _power.power_down_to_id.is_empty():
		health_component.sub_health(tag.get_tag(&"damage", 1) as float)
		if health_component.health <= 0: # No hp -> death
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

## Makes the character die with [signal died] emitted
func die(_tag: TagsObject = TagsObject.new()) -> void:
	if ObjectState.is_state(self, STATE_UNDYABLE):
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
#endregion


#region == Setgets ==
## Sets the power id of the character and put the power into application, if possible
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
			_behavior = i.behavior
			
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

## Returns current [CharacterPower2D]
func get_power() -> CharacterPower2D:
	return _power

## Returns the behavior of current power
func get_behavior() -> CharacterBehavior2D:
	return _behavior if is_instance_valid(_behavior) else null


## Returns [code]true[/code] if the character is invulnerable
func is_invulnerable() -> bool:
	return _invulnerability != null


## Sets the warping direction, and also controls [member controllable]
func set_warp_direction(to: WarpDir, controllable_control: bool = true) -> void:
	_warp_dir = to
	
	if controllable_control:
		controllable =  _warp_dir != WarpDir.NONE

## Returns current warping direction
func get_warp_direction() -> WarpDir:
	return _warp_dir
#endregion
