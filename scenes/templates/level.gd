extends Node2D

var timer


func _ready() -> void:
	await get_tree().create_timer(1).timeout
	var object: Node = load("res://test.gd").new()
	object.free()
	#implemention._object = null
	#implemention = null



