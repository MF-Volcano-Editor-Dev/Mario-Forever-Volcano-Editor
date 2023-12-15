class_name SpriteFacing extends Component

@export_category("Sprite Facing")
@export var property_path: NodePath

var _node: Node
var _property_path_from_tracked_node: NodePath 

@onready var _root := get_root() as Node2D
@onready var _root_has_flip_h: bool = _root is Sprite2D || _root is AnimatedSprite2D


func _ready() -> void:
	if property_path.is_empty():
		return
	_node = get_node_or_null(NodePath(property_path.get_concatenated_names()))
	_property_path_from_tracked_node = NodePath(property_path.get_concatenated_subnames())

func _process(_delta: float) -> void:
	if disabled || property_path.is_empty():
		return
	var _facing = _node.get_indexed(_property_path_from_tracked_node)
	if (_facing is float || _facing is int) && _root_has_flip_h:
		@warning_ignore("integer_division")
		# NOTE:
		# flip = -dir_int + 1 / 2 (right-facing as default, when flip_h = false)
		# dir_int = 1: flip = (1 * -1 + 1) / 2 = 0 => false (right-facing)
		# dir_int = -1: flip = (-1 * -1) + 1 / 2 = 1 => true (left-facing)
		_root.flip_h = bool((-int(signf(_facing if !is_zero_approx(_facing) else 1.0)) + 1) / 2)
