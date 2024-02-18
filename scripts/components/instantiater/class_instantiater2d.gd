@icon("res://icons/instantiater_2d.svg")
class_name Instantiater2D extends Component2D

## A 2D component used for instantiating children [CanvasItem]s.
##
## This component will turn its children [Node]s into [InstancePlaceholder] to prevent them from being ready,
## which will greatly help developers visually plan and edit things like projectiles.[br]
## [br]
## [b]Note 1:[/b] This only works for instances instantiated via [PackedScene]. Otherwise, the node will not be registered by this component.
## [b]Note 2:[/b] The public functions in this class have two parameters with the same name respectively - [param as_child_of_root] and [param filter_node_groups].
## The former determines whether the instance created is added as the sibling of the [member Component2D.root], or as the child of it; and the latter decides that only nodes [u]without[/u] the given node group are able to be instantiated.

## Emitted when an instance is created.[br]
## [br]
## [b]Note:[/b] The emission of the signal is [u]before[/u] the creation of an instance by default, so if you want it to be emitted after the creation, please connect the signal in deferred mode.
signal instance_created(ins: CanvasItem)

var _instances: Array[PackedScene]


func _enter_tree() -> void:
	for i in get_children():
		if !i is CanvasItem:
			continue
		
		remove_child(i) # Removes children to stop them from calling `_enter_tree()` and `_ready()`
		
		# Packs the instances as PackedScenes to save more RAM
		(func() -> void:
			var packed: PackedScene = PackedScene.new()
			packed.pack(i)
			_instances.append(packed)
			i.free()
		).call_deferred()

#func _notification(what: int) -> void:
	#match what: # To prevent from unexpected behaivors in @tool mode, \when !Engine.is_editor_hint()\ is needed
		#NOTIFICATION_ENTER_TREE when !Engine.is_editor_hint(): # Register children CanvasItem-s
			#pass
		#NOTIFICATION_PREDELETE when !Engine.is_editor_hint(): # Destructor: Delete referenced instances
			#_instances = []


# Instantiates an instance
func _instantiate(instance: PackedScene, as_child_of_root: bool = false, filter_node_groups: Array[StringName] = []) -> CanvasItem:
	var ins: CanvasItem = instance.instantiate() as CanvasItem
	
	if !ins:
		ins.free()
		return null
	for i in filter_node_groups:
		if ins.is_in_group(i):
			ins.free()
			return
	
	if root:
		(func() -> void:
			if ins is Control: # Control doesn't have `transform` or `global_transform` property
				var trans: Transform2D = global_transform * ins.get_transform()
				ins.position = trans.get_origin()
				ins.rotation = trans.get_rotation()
				ins.scale = trans.get_scale()
			elif ins is Node2D:
				ins.global_transform = global_transform * ins.transform
			(root.add_child if as_child_of_root else root.add_sibling).call(ins)
		).call_deferred()
	
	instance_created.emit(ins) # This will be emitted before the previous piece of codes being executed
	
	return ins


#region == Instantiation ==
## Instantiate a child instance by [param index].
func instantiate(index: int, as_child_of_root: bool = false, filter_node_groups: Array[StringName] = []) -> CanvasItem:
	if (index >= 0 && index > _instances.size() - 1) || \
		(index < 0 && absi(index) > _instances.size()):
			printerr("Invalid index %s for instantiation!" % str(index))
			return null
	return _instantiate(_instances[index], as_child_of_root, filter_node_groups)

## Instantiate multiple instances from [param index_from] to [param index_to].[br]
## [br]
## [b]Note:[/b] Unlike [method instantiate], you CANNOT input a minus value for [param index_from] or [param index_to].
func instantiate_multiple(index_from: int, index_to: int, as_children_of_root: bool = false, filter_node_groups: Array[StringName] = []) -> Array[CanvasItem]:
	var rst: Array[CanvasItem] = [] # Results
	
	if (index_from < 0 || index_to < 0) || (index_from > index_to):
		printerr("Invalid index range, or minus index(es)!")
		return rst
	
	for i in range(index_from, index_to + 1):
		rst.append(_instantiate(_instances[i], as_children_of_root, filter_node_groups)) # Creates instance (deferred) and register the instance into the list
	
	return rst # Returns the list

## Instantiate all instances.
func instantiate_all(as_children_of_root: bool = false, filter_node_groups: Array[StringName] = []) -> Array[CanvasItem]:
	var rst: Array[CanvasItem] = [] # Result
	
	for i in _instances:
		rst.append(_instantiate(i, as_children_of_root, filter_node_groups))
	
	return rst

## Instantiate a child instance by [param type].
func instantiate_by_type(type: Object, as_child_of_root: bool = false, filter_node_groups: Array[StringName] = []) -> CanvasItem:
	for i in _instances:
		if !is_instance_of(i, type):
			continue
		return _instantiate(i, as_child_of_root, filter_node_groups)
	return null
#endregion
