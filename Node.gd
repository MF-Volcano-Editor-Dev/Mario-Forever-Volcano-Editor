extends Node


func _ready() -> void:
	var a = Node.new()
	add_child(a)
	a.name = "1"
	var b = a.duplicate()
	add_child(b)
	b.name = "2"
	b.queue_free()
	print(a)
