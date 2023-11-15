class_name AreaFluid2D extends EntityArea2D

# #fluid_spray_triggerible

@export var fluid_id: StringName
@export_group("Fluid Spray")
@export var spray: PackedScene

var _in_fluid_body: Array[Node2D]


func _ready() -> void:
	await get_tree().physics_frame
	area_entered.connect(_spray_trigger_area.bind(true))
	area_exited.connect(_spray_trigger_area.bind(false))


func _spray_trigger_area(area: Area2D, is_entering: bool) -> void:
	if is_entering:
		if area in _in_fluid_body:
			return
		_in_fluid_body.append(area)
	else:
		if !area in _in_fluid_body:
			return
		_in_fluid_body.erase(area)
	
	if area.is_in_group(&"#fluid_spray_triggerible"):
		create_spray(area, Transform2D(0, area.global_scale, area.global_skew, area.global_position))


## Create [member spray] effect on a body with [param transform] preset
func create_spray(body: Node2D, p_transform: Transform2D) -> void:
	if !spray:
		return
	
	var s := spray.instantiate()
	if !s is Node2D:
		s.queue_free()
		return
	
	s = s as Node2D
	s.global_transform = p_transform
	body.add_sibling.call_deferred(s)
