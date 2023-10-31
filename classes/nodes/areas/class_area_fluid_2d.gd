class_name AreaFluid2D extends Area2D

# "#fluid_spray_triggerible"

@export var fluid_id: StringName
@export_group("Fluid Spray")
@export var spray: PackedScene


func _ready() -> void:
	# Area entering and exiting
	area_entered.connect(_spray_trigger)
	area_exited.connect(_spray_trigger)
	# Body entering and exiting
	body_entered.connect(_spray_trigger)
	body_exited.connect(_spray_trigger)


func _spray_trigger(body: Node2D) -> void:
	if body.is_in_group(&"#fluid_spray_triggerible"):
		create_spray(body, Transform2D(0, body.global_scale, body.global_skew, body.global_position))


## Create [member spray] effect on a body with [param transform] preset
func create_spray(body: CollisionObject2D, p_transform: Transform2D) -> void:
	if !spray:
		return
	
	var s := spray.instantiate()
	if !s is Node2D:
		s.queue_free()
		return
	
	s = s as Node2D
	body.add_sibling.call_deferred(s)
	s.global_transform = p_transform
