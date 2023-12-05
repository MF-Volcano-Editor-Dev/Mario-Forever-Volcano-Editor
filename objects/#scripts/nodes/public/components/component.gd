@icon("res://icons/component.svg")
class_name Component extends Classes.HiddenNode

## Base class of such ones used under a [Node] to be a tag to provide extra behaviors for the root node.
##
## This is a base node of each component. To disable the node, please turn on [member disabled].[br]
## [br]
## [b]Note:[/b] If you want to extend this class, please ensure you have implemented [member disabled]
## in each place where your component is to work.

@export_category("Component")
## If disabled, the component cannot process. [br]
## [br]
## [b]Note:[/b] For developers who want to extend this class, please implement methods with
## this property to ensure the methods you are going to define are controllable.
@export var disabled: bool:
	set = set_disabled
## [NodePath] to the root node
@export var root_path: NodePath = ^".."


#region == Setgets ==
func set_disabled(value: bool) -> void:
	disabled = value

## Returns the root node
func get_root() -> Node:
	var root := get_node_or_null(root_path)
	return root if is_instance_valid(root) else null
#endregion
