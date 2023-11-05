class_name AreaFluid2D extends Area2D

# "#fluid_spray_triggerible"

@export var fluid_id: StringName
@export_group("Fluid Spray")
@export var spray: PackedScene


func _ready() -> void:
	area_entered.connect(_spray_trigger_area)
	area_exited.connect(_spray_trigger_area)


func _spray_trigger_area(area: Node2D) -> void:
	var bd := area.get_parent()
	if bd is Node2D && area.is_in_group(&"#fluid_spray_triggerible"):
		create_spray(bd, Transform2D(0, bd.global_scale, bd.global_skew, bd.global_position))


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
