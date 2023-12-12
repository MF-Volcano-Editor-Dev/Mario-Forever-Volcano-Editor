class_name Instantiater extends Classes.HiddenMarker2D

## Abstract base class for each [b]2D node[/b] that needs to create
## [b]2D scenes[/b] instances.
##
## [b]Note:[/b] You should add an exported property in the extending classes for
## direct access to the modification of the packed scene you want this node to
## instantiate.

signal instance_created(instance: Node2D) ## Emitted when an instance from the given [PackedScene] is instantiated.

## Contains the modes of [method instantiate].
enum CreatingMode {
	CHILD_OF_SELF, ## In this mode, the instance will be added as a child of this node.
	SIBLING_OF_SELF, ## In this mode, the instance will be added as a sibling of this node.
	SIBLING_OF_ROOT, ## In this mode, the instance will be added as a sibling of the root node of this node.
}

@export_category("Instantiater")
@export_node_path("Node2D") var root_path: NodePath = ^".."
@export_group("Instantiation")
@export var creating_mode: CreatingMode = CreatingMode.SIBLING_OF_ROOT
@export_group("Instance Settings", "instance")
@export var instance_order: int = 0
@export_range(-4096, 4096, 1) var instance_z_index: int = 0
@export var instance_modulate: Color = Color.WHITE
@export var instance_visible: bool = true

@onready var _root := get_root()


#region == Instantiation ==
func instantiate(packed_scene: PackedScene, offset: Vector2 = Vector2.ZERO) -> Node2D:
	if !packed_scene:
		return null
	
	var ins := packed_scene.instantiate()
	if !ins is Node2D:
		ins.queue_free() # Don't forget to manually remove the instance that is not a Node2D
		return null
	ins = ins as Node2D # Cast for better coding hints
	
	var adjust_index := func(node: Node, child: Node) -> void:
		node.get_parent().move_child.call_deferred(child, get_index() + instance_order)
	match creating_mode:
		CreatingMode.CHILD_OF_SELF:
			add_child.call_deferred(ins)
			adjust_index.call(self, ins)
		CreatingMode.SIBLING_OF_SELF:
			add_sibling.call_deferred(ins)
			adjust_index.call(self, ins)
		CreatingMode.SIBLING_OF_ROOT:
			_root.add_sibling.call_deferred(ins)
			adjust_index.call(_root, ins)
	
	ins.global_transform = global_transform.translated_local(offset)
	ins.z_index = instance_z_index
	ins.modulate = instance_modulate
	ins.visible = instance_visible
	
	instance_created.emit(ins)
	return ins
#endregion

#region == Getters ==
func get_root() -> Node2D:
	return get_node(root_path) as Node2D
#endregion
