@tool
class_name SplitScreen extends SubViewportContainer

const _DEFAULT_MASK: int = 0b10000000000000000000

@export_node_path("CanvasItem") var canvas_item: NodePath = ^".":
	set(value):
		canvas_item = value
		if is_queued_for_deletion():
			return
		_set_world()
		notify_property_list_changed()

var _inited: bool
var sub_viewport: SubViewport


func _ready() -> void:
	if !_inited:
		stretch = true
		light_mask = _DEFAULT_MASK
		visibility_layer = _DEFAULT_MASK
	
	if !sub_viewport || !is_instance_valid(sub_viewport):
		sub_viewport = SubViewport.new()
		add_child(sub_viewport, true)
		sub_viewport.owner = get_parent()
		sub_viewport.canvas_cull_mask = ~(visibility_layer | light_mask) # To prevent bugs
	
	_set_world()
	_inited = true


func _set(property: StringName, value: Variant) -> bool:
	match property:
		&"visibility_layer":
			visibility_layer = value
			sub_viewport.canvas_cull_mask = ~(visibility_layer | light_mask)
			return true
		&"light_mask":
			light_mask = value
			sub_viewport.canvas_cull_mask = ~(visibility_layer | light_mask)
			return true
	return false

func _property_can_revert(property: StringName) -> bool:
	match property:
		&"stretch", &"light_mask", &"visibility_layer":
			return true
	return false

func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"stretch":
			return true
		&"light_mask":
			return _DEFAULT_MASK
		&"visibility_layer":
			return _DEFAULT_MASK
	return null

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append({
		name = &"sub_viewport",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_NODE_TYPE,
		hint_string = "SubViewport",
		usage = PROPERTY_USAGE_NO_EDITOR
	})
	properties.append({
		name = &"_inited",
		type = TYPE_BOOL,
		hint = PROPERTY_HINT_NONE,
		hint_string = "",
		usage = PROPERTY_USAGE_NO_EDITOR
	})
	return properties


func _set_world() -> void:
	var canvas := get_node_or_null(canvas_item) as CanvasItem
	if !sub_viewport || !canvas:
		return
	sub_viewport.world_2d = canvas.get_world_2d()
