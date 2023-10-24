class_name Component extends Node

## Class that used under a [Node] to be a tag to provide
## extra behaviors for the tagged node
##
##


@export_enum("Node: 0", "Path String: 1") var root_selection_mode: int = 0
@export var root: Node
@export var root_as_string: String


func _ready() -> void:
	match root_selection_mode:
		0 when !is_instance_valid(root):
			root = null
		1 when !root_as_string.is_empty():
			root = get_node_or_null(root_as_string)
