class_name Process


static func get_delta(node: Node) -> float:
	return node.get_physics_process_delta_time() if Engine.is_in_physics_frame() else node.get_process_delta_time()
