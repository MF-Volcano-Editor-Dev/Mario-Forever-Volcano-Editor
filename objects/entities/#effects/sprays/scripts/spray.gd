extends Node2D

@export_category("Spray")
@export var target_fluid_id: StringName
@export_group("Collision")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px") var actual_fluid_detection_radius: float = 8

@onready var caster: ShapeCast2D = $ShapeCast2D


func _ready() -> void:
	caster.force_shapecast_update()
	
	if !caster.is_colliding():
		return
	
	var n: Vector2 = caster.get_collision_normal(0)
	if n:
		global_rotation = n.angle() + PI/2
	
	var cl := caster.get_collider(0) as AreaFluid2D
	if !cl || cl.fluid_id != target_fluid_id:
		return
	
	caster.shape = caster.shape.duplicate() as CircleShape2D
	caster.shape.radius = actual_fluid_detection_radius
	caster.force_shapecast_update()
	
	var inout: bool = !caster.is_colliding()
	var down: Vector2 = Vector2.DOWN.rotated(global_rotation)
	
	match inout:
		true:
			for i in 128:
				global_position += down
				caster.force_shapecast_update()
				
				if caster.get_collision_count():
					global_position -= down
					return
		false:
			for i in 16:
				global_position -= down
				caster.force_shapecast_update()
				
				if !caster.get_collision_count():
					return
	
	queue_free()
