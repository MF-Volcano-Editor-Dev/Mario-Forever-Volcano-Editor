class_name Component extends Node

## Class that used under a [Node] to be a tag to provide
## extra behaviors for the tagged node
##
##

@export var root: Node:
	set = set_root


func set_root(new_root: Node) -> void:
	if !is_instance_valid(new_root):
		return
	root = new_root
