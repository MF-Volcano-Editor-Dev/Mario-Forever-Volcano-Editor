class_name Process

## Static class provides methods related to process.


## Returns the delta time according to the place where the code is typed.[br]
## If in [method Node._process], then return _process()'s.[br]
## And if in [method Node._physics_process], then return _physics_process()'s.
static func get_delta(node: Node) -> float:
	return node.get_physics_process_delta_time() if Engine.is_in_physics_frame() else node.get_process_delta_time()


#region == Node getting ==
## Gets a child of [param from] with certain [param type].[br]
## If no specified type of node is detected, then returns [code]null[/code].
static func get_child(from: Node, type: Object) -> Node:
	for i: Node in from.get_children():
		if is_instance_of(i, type):
			return i
	return null

## Iterates nodes and find one including their multilevel children.[br]
## If no specified type of node is detected, then returns [code]null[/code].
## [br]
## [b]Note:[/b] This method will be performance-costing if you call it in the process methods.
## So be careful before you use this function.
static func get_child_iterate(from: Node, type: Object) -> Node:
	for i: Node in from.get_children():
		if is_instance_of(i, type):
			return i
		elif i.get_child_count():
			return get_child_iterate(i, type)
	return null

## Gets a child of [param from] in certain [param group].
## If no any node is fit for the specific group, then returns [code]null[/code].
static func get_child_in_group(from: Node, group: StringName) -> Node:
	for i: Node in from.get_children():
		if !i.is_in_group(group):
			continue
		return i
	return null
#endregion

#region == Readiness ==
## Await the readiness of a [param node] [br]
## [b]Note:[/b] You should use [code]await[/code] to get the correct use of the method
static func await_readiness(node: Node) -> void:
	if !node.is_node_ready():
		await node.ready

## Await the readiness of the current scene, see [method await_readiness] to get more details
static func await_current_scene_readiness(tree: SceneTree, quit_when_invalid: bool = false) -> void:
	while !quit_when_invalid && !is_instance_valid(tree.current_scene):
		await tree.process_frame
	await await_readiness(tree.current_scene)
#endregion


static func print_used_usec(function: Callable) -> void:
	var t := Time.get_ticks_usec()
	function.call()
	print(Time.get_ticks_usec() - t)
