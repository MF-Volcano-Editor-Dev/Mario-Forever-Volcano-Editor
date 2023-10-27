class_name Process

## Static class provides methods related to process


## Returns the delta time according to the place where the code is typed [br]
## If in [method Node._process], then return _process()'s [br]
## And if in [method Node._physics_process], then return _physics_process()'s
static func get_delta(node: Node) -> float:
	return node.get_physics_process_delta_time() if Engine.is_in_physics_frame() else node.get_process_delta_time()
