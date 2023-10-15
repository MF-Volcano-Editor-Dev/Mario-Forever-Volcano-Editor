class_name MarioSuit2D extends Node2D

@export_group("General")
@export var character_id: StringName = &"mario"
@export var suit_id: StringName = &"small"

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer


func deploy(on: Mario2D) -> void:
	if !is_instance_valid(on):
		return
	
	for i in get_children():
		i.reparent.call_deferred(on, false)
	
	queue_free()


##regionbegin Animations
func appear(duration: float = 1.0) -> void:
	animation.play(&"Mario/appear")
	await get_tree().create_timer(duration, false).timeout
	animation.play(&"Mario/RESET")
##endregion
