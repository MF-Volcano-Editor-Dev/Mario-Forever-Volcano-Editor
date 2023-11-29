class_name Classes

## A static class storing path to certain scripts.
##
## This class is referred to provide class references as valid identifiers
## in the editor, which helps you to get coding hint when using typed style.[br]
## [br]
## [b]Note:[/b] Some classes prefixed with [u]Hidden[/u] are used to make inheriting
## ones hidden from the node dock to keep it clean and natural, while the
## [code]class_name[/code] maintains working and you can still refer to a class beginning
## with this key word as usual. However, if one of the following situations happen,
## please restart the editor:[br]
## > 1: The reference path to a script is changed.[br]
## > 2: The content of a script is changed, but sometimes you can keep editor open.[br]
## > 3: A new script referred by this script is attached in it.

#region HiddenClasses
const HiddenNode := preload("res://objects/#scripts/nodes/hidden/class_hidden_node.gd")
const HiddenNode2D := preload("res://objects/#scripts/nodes/hidden/class_hidden_node_2d.gd")
const HiddenCamera2D := preload("res://objects/#scripts/nodes/hidden/class_hidden_camera_2d.gd")
const HiddenEntityBody2D := preload("res://objects/#scripts/nodes/hidden/class_hidden_entity_body_2d.gd")
const HiddenMarker2D := preload("res://objects/#scripts/nodes/hidden/class_hidden_marker_2d.gd")
const HiddenCanvasLayer := preload("res://objects/#scripts/nodes/hidden/class_hidden_canvas_layer.gd")
#endregion
