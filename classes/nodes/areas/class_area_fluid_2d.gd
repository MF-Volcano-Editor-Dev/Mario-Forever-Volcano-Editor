class_name AreaFluid2D extends Area2D

# "#fluid_spray_triggerible"

@export var fluid_id: StringName
@export_group("Fluid Spray")
@export var spray: PackedScene


func _ready() -> void:
	# Area entering and exiting
	area_entered.connect(_spray_trigger.bind(1))
	area_exited.connect(_spray_trigger.bind(-1))
	# Body entering and exiting
	body_entered.connect(_spray_trigger.bind(1))
	body_exited.connect(_spray_trigger.bind(-1))


func _spray_trigger(body: Node2D, entering: int) -> void:
	if body.is_in_group(&"#fluid_spray_triggerible"):
		create_spray(body, Transform2D(0, body.global_scale, body.global_skew, body.global_position), entering)


## Create [member spray] effect on a body with [param transform] preset
func create_spray(body: CollisionObject2D, p_transform: Transform2D, entering: int = 0) -> void:
	if !spray:
		return
	
	var s := spray.instantiate() as Node2D
	body.add_sibling.call_deferred(s)
	
	s.global_transform = p_transform
	s.set_entering(entering)
