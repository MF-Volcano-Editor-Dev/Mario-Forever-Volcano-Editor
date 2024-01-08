@icon("res://icons/component.svg")
class_name Component extends Node

## Abstract base class of such nodes that provides extra functions for other nodes, or help these nodes with some process.
##
## [b]Note 1:[/b] Generally, [member root] should be manually set in order to make the component work as expected, though some components have no any requirement on it.[br]
## [b]Note 2:[/b] If you want to get a more specific type of [member root] please cast the member with [code]as[/code]:
## [codeblock]
## var specific: Type = root as Type # Type should be the child of Node!
## [/codeblock]

## The [Node] that the component takes effect on
@export var root: Node
