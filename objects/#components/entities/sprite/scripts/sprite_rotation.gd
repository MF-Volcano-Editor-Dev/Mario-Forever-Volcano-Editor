class_name SpriteRotation extends Component

@export_category("Sprite Rotation")
@export var property_path: NodePath
@export_range(-18000, 18000, 0.001, "°/s") var rotation_speed: float

var _prev_dir: bool
var _node: Node
var _property_path_from_tracked_node: NodePath 

@onready var _root := get_root() as Node2D


func _ready() -> void:
	if property_path.is_empty():
		return
	_node = get_node_or_null(NodePath(property_path.get_concatenated_names()))
	_property_path_from_tracked_node = NodePath(property_path.get_concatenated_subnames())

func _process(delta: float) -> void:
	if disabled || property_path.is_empty():
		return
	var _facing = _node.get_indexed(_property_path_from_tracked_node)
	if (_facing is float || _facing is int):
		var facing_not_zero := !is_zero_approx(_facing)
		_root.rotate(signf(_facing if facing_not_zero else 1.0) * deg_to_rad(rotation_speed * delta))
		_prev_dir = _facing if facing_not_zero else _prev_dir
