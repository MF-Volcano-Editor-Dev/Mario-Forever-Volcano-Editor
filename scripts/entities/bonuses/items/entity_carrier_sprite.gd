@tool
extends Sprite2D

var _par: ItemWalker2D


func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		return
	if !_par:
		_par = get_parent()
	elif texture != _par.display:
		texture = _par.display
