@tool
extends Node2D

var par: QuestionBlock2D


func _ready() -> void:
	if !Engine.is_editor_hint():
		queue_free()
		return
	visibility_changed.connect(set_process.bind(visible))

func _draw() -> void:
	if !par:
		return
	if par.items.is_empty():
		return
	if !par.items[0]:
		return
	
	draw_texture(par.items[0].icon, Vector2.ZERO)

func _process(_delta: float) -> void:
	if !par:
		par = get_parent() as QuestionBlock2D
	if !par:
		return
	
	queue_redraw()
