class_name QuestionBlock2D extends BumpBlock2D

@export var item: Array[Resource]


func _bump_process(_bumper: Node2D, _touch_spot: Vector2) -> void:
	super(_bumper, _touch_spot)
