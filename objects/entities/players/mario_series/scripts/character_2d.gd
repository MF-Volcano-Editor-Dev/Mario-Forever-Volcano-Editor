class_name CharacterEntity2D extends Classes.HiddenEntityBody2D

## Basic class of characters in this template project
##
## [b]Note:[/b] Because this template aims to help developers with Mario Forever fangames,
## if you have characters out of Super Mario Series implemented, this class will transform some of their
## behaviors to mario style, like getting hurt and death!

signal hurt ## Emitted when the character gets hurt
signal died ## Emitted when the character is dead

enum WarpDir {
	NONE = 0,
	UP = -1,
	DOWN = 1,
	LEFT = -2,
	RIGHT = 2
}

const ON_SWIMMING := &"on_swimming"
const IS_CONTROLLABLE := &"controllable"
const PHYSICS_OVERWORLD := &"physics_overworld"


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
@export var nickname: StringName = &"Player"
@export_group("Power")
@export var power_id: StringName = &"small":
	set = set_power_id
@export var power_disable_appear: bool = true
@export_group("Physics")
@export_enum("Left: -1", "Right: 1") var direction: int = 1:
	set(value):
		direction = value if value != 0 else [-1, 1].pick_random()

# Node getting
@onready var body := get_node(path_body) as Area2D
@onready var head := get_node(path_head) as Area2D
@onready var health_component := get_node(path_health_component) as HealthComponent

#region == Status ==
var _is_controllable: bool = true
#endregion

#region == Data ==
var _key_input_directions: Vector2i # Directions of key input
var _warp_dir: WarpDir = WarpDir.NONE # Warping direction
#endregion

#region == References ==
var _behavior: CharacterBehavior2D # Reference to a CharacterBehavior2D
#endregion


func _ready() -> void:
	power_id = power_id


#region == Physics ==
func accelerate_walking(acce: float, to: float) -> void:
	accelerate_speed(acce, to * direction)

func decelerate_walking(dece: float) -> void:
	accelerate_speed(dece, 0)
#endregion


#region == Setgets ==
func set_power_id(value: StringName) -> void:
	if !is_node_ready():
		await ready
	
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


func get_behavior() -> CharacterBehavior2D:
	return _behavior if is_instance_valid(_behavior) else null


func set_warp_direction(to: WarpDir, controllable_control: bool = true) -> void:
	_warp_dir = to
	
	if controllable_control:
		if _warp_dir != WarpDir.NONE:
			set_controllable(true)
		else:
			set_controllable(false)

func get_warp_direction() -> WarpDir:
	return _warp_dir


func set_controllable(value: bool) -> void:
	_is_controllable = value

func is_controllable() -> bool:
	return _is_controllable


func set_key_input_directions(left: StringName, right: StringName, up: StringName, down: StringName) -> void:
	var _id: StringName = str(id)
	_key_input_directions = Vector2i(Input.get_vector(left + _id, right + _id, up + _id, down + _id).normalized().sign())

func get_key_input_directions() -> Vector2i:
	return _key_input_directions
#endregion
