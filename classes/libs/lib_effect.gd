class_name Effect

## Static class used to provide effects for a [CanvasItem]
##
##


static func flash(canvas_item: CanvasItem, duration: float, interval: float = 0.05) -> void:
	var alpha: float = canvas_item.modulate.a
	
	var tween: Tween = canvas_item.create_tween().set_trans(Tween.TRANS_SINE).set_loops(ceili(duration / interval))
	tween.tween_property(canvas_item, "modulate:a", 0, interval / 2)
	tween.tween_property(canvas_item, "modulate:a", 1, interval / 2)
	
	await tween.finished
	tween.kill()
	
	canvas_item.modulate.a = alpha
