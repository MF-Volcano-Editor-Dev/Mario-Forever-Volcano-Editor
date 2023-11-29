class_name CharacterEntity2D extends Classes.HiddenEntityBody2D

## Basic class of Super Mario Systemized characters.
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

## Warping directions, if not [code]NONE[/code], the player is not on warping, otherwise it is [br]
## This is used to assign warping animations
enum WarpDir {
	NONE = 0, ## Not warping
	UP = -1, ## Warping animation - jump
	DOWN = 1, ## Warping animation - crouch
	LEFT = -2, ## Warping animation - walking left
	RIGHT = 2 ## Warping animation - walking right
}

@export_category("Character")
@export_group("Component Links", "path_")
## Path to an [Area2D] as the body detector of the player
@export_node_path("Area2D") var path_body: NodePath = ^"AreaBody"
## Path to an [Area2D] as the head detector of the player
@export_node_path("Area2D") var path_head: NodePath = ^"AreaHead"
@export_node_path("Node") var path_health_component: NodePath = ^"HealthComponent"
@export_group("Core Info")
## Id of the character. Different ID will register different players
@export_range(0, 3, 1, "suffix:No.") var id: int
## Nickname of the character
@export var nickname: StringName = &"Player"
@export_group("Power")
@export var power_id: StringName = &"small":
	set = set_power_id
@export var power_disable_appear: bool = true
@export_group("Physics")
@export_enum("Left: -1", "Right: 1") var direction: int = 1:
	set(value):
		direction = value if value != 0 else [-1, 1].pick_random()
@export_group("State Controls")
@export var controllable: bool = true
@export_group("Death")
@export var death: PackedScene

# Node getting
@onready var body := get_node(path_body) as Area2D
@onready var head := get_node(path_head) as Area2D
@onready var health_component := get_node(path_health_component) as HealthComponent

#region == Data ==
var _key_input_directions: Vector2i # Directions of key input
var _warp_dir: WarpDir = WarpDir.NONE # Warping direction
#endregion

#region == References ==
var _invulnerability: SceneTreeTimer
var _behavior: CharacterBehavior2D # Reference to a CharacterBehavior2D
#endregion


func _ready() -> void:
	var cmdl := CharactersManager2D.get_characters_data_list()
	cmdl.register(self)
	power_id = power_id


#region == Physics ==
## Accelerates [member EntityBody2D.speed] to a certain value, with direction considered
func accelerate_walking(acce: float, to: float) -> void:
	accelerate_local_x(acce, to * direction)

## Decelerates [member EntityBody2D.speed] to zero
func decelerate_walking(dece: float) -> void:
	accelerate_local_x(dece, 0)
#endregion


#region == Health controls ==
func damaged(tag: TagsObject = null) -> void:
	if ObjectState.is_state(self, STATE_UNDAMAGIBLE) || !tag.get_tag(&"forced", false):
		return

func die(_tag: TagsObject = null) -> void:
	if ObjectState.is_state(self, STATE_UNDYABLE):
		return
#endregion


#region == Setgets ==
## Sets the power id of the character and put the power into application, if possible
func set_power_id(value: StringName) -> void:
	await Process.await_readiness(self)
	
	var power_ext: bool = false # Is power existing
	for i: Node in get_children():
		if !i is CharacterPower2D:
			continue
		
		i = i as CharacterPower2D
		if i.power_id == value:
			power_ext = true
			
			i.process_mode = process_mode
			i.behavior._behavior_ready() # Called when the suit is current
			_behavior = i.behavior
			
			if power_disable_appear:
				power_disable_appear = false
			else:
				i.appear()
		else:
			i.behavior._behavior_disready() # Called when the suit is NOT current
			i.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Set the value if the power exists, or send an error if not
	if power_ext:
		power_id = value
	else:
		printerr("Non-existing power id %s!" % value)

## Returns behavior of the current power
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


## Sets the direction of key input
func set_key_input_directions(left: StringName, right: StringName, up: StringName, down: StringName) -> void:
	var _id: StringName = str(id)
	_key_input_directions = Vector2i(Input.get_vector(left + _id, right + _id, up + _id, down + _id).normalized().sign()) if controllable else Vector2i.ZERO

## Returns the direction of key input
func get_key_input_directions() -> Vector2i:
	return _key_input_directions
#endregion
