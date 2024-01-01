@icon("res://icons/component.svg")
class_name Component extends Node

## Abstract base class of components that provides extra functions for other nodes, or help these nodes with some process.
##
## [b]Notes:[/b][br]
## 1. [member root] should be manually set to make the component work as expected.[br]
## 2. [method get_root] supports covariant, so if the function is overriden by a child class, the type of returned value can be any child type of [Node]:
## [codeblock]
## class_name MyComponent extends Component
##
##
## func get_root() -> Node2D: # Node2D is a child type of Node
##     return root as Node2D 
##     # Needs casting to ensure the casting process is safe, and will return a `null` if the `root` is not a child type of Node.
## [/codeblock]

## The [Node] that the component takes effect on
@export var root: Node:
	get = get_root


## [code]Override if necessary[/code]
## Returns [member root]
func get_root() -> Node:
	return root
