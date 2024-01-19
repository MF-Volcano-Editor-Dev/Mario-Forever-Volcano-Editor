extends State

@export_category("Character Non-climbing State")
@export_group("References")
@export var animated_sprite: AnimatedSprite2D
@export var shape_controller: AnimationPlayer
@export var head: Area2D
@export var body: Area2D
@export_group("Physics")
@export_subgroup("Walking")
## Initial walking speed.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_speed: float = 50
## Acceleration.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var acceleration: float = 312.5
## Deceleration.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var deceleration: float = 312.5
## Deceleration scale when crouching.
@export_range(0, 5, 0.001, "hide_slider", "suffix:x") var deceleration_scale_crouch: float = 2
## Deceleration on turning back.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var walking_turning_deceleration: float = 1250
## Max walking speed.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_walking_speed: float = 175
## Max running speed.[br]
## [br]
## [b]Note:[/b] If the character is underwater, this is equal to [member max_walking_speed]
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_running_speed: float = 350
@export_subgroup("Jumping")
## Initial jumping speed.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_jumping_speed: float = 700
## Jumping acceleration when walking speed is lower than 10.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var jumping_acceleration_static: float = 1000
## Jumping acceleration when walking speed is greater than or equal to 10.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var jumping_acceleration_dynamic: float = 1250
@export_subgroup("Swimming", "swimming_")
## Swimming strength, the speed when, underwater, the jumping key is pressed.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var swimming_strength: float = 150
## Swimming strength when the character is about to jump out of the water surface.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var swimming_strength_jumping_out: float = 450
## Max speed of swimming up.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var swimming_up_max_speed: float = 150

var _temp_character_info: Dictionary = {
	gravity_scale = 0.0,
	max_falling_speed = 0.0,
}

@onready var _character: Character = root.get_parent()


func _state_process(delta: float) -> void:
	_animation.call_deferred(delta) # Called at the end of a frame to make sure the animation will be correctly played if the character is walking against a wall

func _state_physics_process(delta: float) -> void:
	_character.calculate_gravity()
	_character.move_and_slide()


#region == Animations ==
func _animation(delta: float) -> void:
	if !animated_sprite:
		return
	if animated_sprite.animation in [&"appear", &"attack"]:
		return
	
	if _character.is_on_floor():
		var real_vel: Vector2 = _character.get_real_velocity()
		if !real_vel.slide(_character.get_floor_normal()).is_zero_approx():
			animated_sprite.play(&"walk")
		else:
			animated_sprite.play(&"default")
	elif _character.get_meta(&"underwater", false):
		animated_sprite.play(&"swim")
	elif _character.is_falling():
		animated_sprite.play(&"fall")
	else:
		animated_sprite.play(&"jump")
#endregion
