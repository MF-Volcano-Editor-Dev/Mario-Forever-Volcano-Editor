class_name SpriteFacing extends Component

@export_category("Sprite Facing")
@export var property_path: NodePath

var _node: Node
var _property_path_from_tracked_node: NodePath 

@onready var _root := get_root() as Node2D


func _ready() -> void:
	if property_path.is_empty():
		return
	_node = get_node_or_null(NodePath(property_path.get_concatenated_names()))
	_property_path_from_tracked_node = NodePath(property_path.get_concatenated_subnames())

func _process(_delta: float) -> void:
	if disabled || property_path.is_empty():
		return
	var _facing = _node.get_indexed(_property_path_from_tracked_node)
	if _facing is float:
		_root.scale.x *= signf((_facing if _facing else 1.0) * _root.scale.x)
