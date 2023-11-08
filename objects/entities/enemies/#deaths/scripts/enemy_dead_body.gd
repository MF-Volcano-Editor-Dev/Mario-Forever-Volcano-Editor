extends Node2D

@export_category("Enemy Death")
@export_subgroup("Initial")
@export_range(-90, 90, 0.001, "degrees") var thrown_angle: float = 30
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_speed_min: float = 100
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_speed_max: float = 200
@export_group("Gravity")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var gravity: float = 500
@export var gravity_direction: Vector2 = Vector2.DOWN:
	set(value):
		gravity_direction = value.normalized()
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_falling_speed: float = 1500

var thrown_direction: Vector2 = Vector2.UP:
	set(value):
		thrown_direction = value.normalized()
var global_velocity: Vector2
var direction: int = 1:
	set(value):
		direction = value
		if direction == 0:
			direction = [-1, 1].pick_random()


func _ready() -> void:
	if initial_speed_max > 0:
		var ang := deg_to_rad(thrown_angle)
		global_velocity = thrown_direction.rotated(randf_range(-ang, ang)) * randf_range(initial_speed_min, initial_speed_max)


func _process(delta: float) -> void:
	global_velocity += gravity * gravity_direction * delta
	global_position += global_velocity * delta
