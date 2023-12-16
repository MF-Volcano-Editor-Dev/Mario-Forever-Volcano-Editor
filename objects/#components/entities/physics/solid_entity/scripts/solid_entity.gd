@icon("res://icons/solid_entity.svg")
class_name SolidEntity extends AreaDetectingComponent

## Class used as a child of [Area2D] to make entity able to emit a signal
## when colliding with the other one that contains this node.
##
##

signal collided_entity ## Emitted when the entity collides with the other one with this node

@onready var _root := get_root()


func _ready() -> void:
	_root.area_entered.connect(_on_entity_area_entered)


func _on_entity_area_entered(area: Area2D) -> void:
	if disabled || is_area_ignored(area):
		return
	var solid := Process.get_child(area, SolidEntity)
	if !solid || solid.disabled:
		return
	var entity := area.get_parent() as EntityBody2D
	if !entity:
		return
	entity.turn_wall()
