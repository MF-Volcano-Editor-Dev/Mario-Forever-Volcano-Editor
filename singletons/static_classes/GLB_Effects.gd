class_name Effects


static func flash(node: Node2D, duration: float, interval: float = 0.06) -> void:
	if !is_instance_valid(node):
		return
	
	var a: float = node.modulate.a
	var tw: Tween = node.create_tween().set_trans(Tween.TRANS_SINE).set_loops(int(ceilf(duration / interval)))
	tw.tween_property(node, ^"modulate:a", 0.1, interval / 2)
	tw.tween_property(node, ^"modulate:a", a, interval / 2)
