class_name Rotator extends Component

## Component as a child of [Node2D] to provide rotation according to the given property from [member Component.root]
##
## 

## Callback type of the process method
@export_enum("Idle", "Physics") var process_callback: int:
	set(value):
		process_callback = value
		set_process(process_callback == 0)
		set_physics_process(process_callback == 1)
## Rotation speed of the rotating node
@export_range(-18000, 18000, 0.001, "suffix:°/s") var rotation_speed: float
@export_group("References")
## Path to a [Node2D] to rotate
@export_node_path("Node2D") var rotating_node_path: NodePath = ^".."
## Path to a property in [member Component.root].[br]
## [br]
## This even allows you to assign a more specific property. For example:
## [codeblock]
## # Supposed that the member "velocity" is a Vector2
## velocity:x # This equials to access to "velocity.x"
## [/codeblock]
## [b]Note:[/b] You need to know how to get access to a property by [NodePath].
@export var property_path: String

var _dir: int = 1:
	set(value):
		if value == 0: # Zero direction is not allowed
			return
		_dir = value

@onready var _rotating_node: Node2D = get_node(rotating_node_path)


func _ready() -> void:
	process_callback = process_callback # Triggers setter of `process_callback`
	
	if !root:
		return
	
	var prop = root.get_indexed(property_path) # A Variant type
	if prop is float || prop is int:
		_dir = int(prop)

func _process(delta: float) -> void:
	_rotate(delta)

func _physics_process(delta: float) -> void:
	_rotate(delta)


func _rotate(delta: float) -> void:
	_rotating_node.rotate(deg_to_rad(rotation_speed) * delta * _dir)
