@icon("res://icons/instantiater_2d.svg")
class_name Instantiater2D extends Component2D

## A 2D component used for instantiating children [CanvasItem]s.
##
## This component will turn its children [Node]s into [InstancePlaceholder] to prevent them from being ready,
## which will greatly help developers visually plan and edit things like projectiles.[br]
## [br]
## [b]Note:[/b] This only works for instances instantiated via [PackedScene]. Otherwise, the node will not be registered by this component.

signal instance_created(ins: CanvasItem) ## Emitted when an instance is created.

var _instances: Array[CanvasItem]


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_POST_ENTER_TREE: # Register children CanvasItem-s
			for i in get_children():
				if !i is CanvasItem:
					continue
				_instances.append(i)
				remove_child(i)
		NOTIFICATION_PREDELETE: # Delete referenced instances
			for i in _instances:
				i.queue_free()


# Instantiates the instance
func _instantiate(instance: CanvasItem, as_child_of_root: bool = false) -> CanvasItem:
	var ins: CanvasItem = instance.duplicate()
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
	
	instance_created.emit(ins)
	
	return ins


#region == Instantiation ==
## Instantiate a child instance by [param index].
func instantiate(index: int, as_child_of_root: bool = false) -> CanvasItem:
	if (index >= 0 && index > _instances.size() - 1) || \
		(index < 0 && absi(index) > _instances.size()):
			printerr("Invalid index %s for instantiation!" % str(index))
			return null
	return _instantiate(_instances[index], as_child_of_root)

## Instantiate a child instance by [param type].
func instantiate_by_type(type: Object, as_child_of_root: bool = false) -> CanvasItem:
	for i in _instances:
		if !is_instance_of(i, type):
			continue
		return _instantiate(i, as_child_of_root)
	return null
#endregion
