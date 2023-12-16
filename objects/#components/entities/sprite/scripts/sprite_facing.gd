class_name SpriteFacing extends Component

## Components that used to flip a [Sprite2D] or [AnimatedSprite2D] by a given property via [member property_path]
##
##

@export_category("Sprite Facing")
@export var property_path: NodePath
@export_enum("Flip H", "Flip V") var flip_mode: int
@export var reversed_flip: bool

var _prev_flip: bool
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
		# NOTE:
		# flip = -dir_int + 1 / 2 (right/down-facing as default, when flip_h/flip_v = false, unless reversed_flip = true)
		# dir_int = 1: flip = (1 * -1 + 1) / 2 = 0 => false (right/down-facing)
		# dir_int = -1: flip = (-1 * -1) + 1 / 2 = 1 => true (left/up-facing)
		var reversed := int(reversed_flip) * 2 - 1
		var facing_not_zero := !is_zero_approx(_facing)
		@warning_ignore("integer_division")
		var flip := bool((reversed * int(signf(_facing if facing_not_zero else _prev_flip)) + 1) / 2)
		_prev_flip = flip if facing_not_zero else _prev_flip
		if flip_mode == 0:
			_root.flip_h = flip
		else:
			_root.flip_v = flip
