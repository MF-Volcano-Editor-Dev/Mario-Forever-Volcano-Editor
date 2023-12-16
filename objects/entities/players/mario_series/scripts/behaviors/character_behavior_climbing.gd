extends CharacterBehavior2D

@export_category("Character Action Climbing")
@export_group("Keys")
@export var key_up: StringName = &"up"
@export var key_down: StringName = &"down"
@export var key_left: StringName = &"left"
@export var key_right: StringName = &"right"
@export var key_jump: StringName = &"jump"
@export_group("Shapes", "shape_")
@export var shape_body: CharacterShape2D = preload("res://objects/entities/players/mario_series/resources/shapes/character_shape_mario_small.tres")
@export var shape_head: CharacterShape2D = preload("res://objects/entities/players/mario_series/resources/shapes/character_head_mario_small.tres")
@export_group("Physics")
@export_subgroup("Climbing")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var climbing_speed: float = 150
@export_subgroup("Jump")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var jumping_speed: float = 600
@export_group("Sounds", "sound_")
@export var sound_jump: AudioStream = preload("res://assets/sounds/jump.wav")

@onready var _animation := get_power().get_animation()


func _process(delta: float) -> void:
	_character.set_key_xy(key_up, key_down, key_left, key_right)
	var vec := Vector2(_character.get_key_xy()).normalized()
	
	# Shapes update
	_character.update_body_collision_shapes(shape_body)
	_character.update_head_collision_shape(shape_head)
	
	# Jumping from climbing
	if _character.is_action_pressed(key_jump):
		Sound.play_sound_2d(_character, sound_jump)
		_character.jump(jumping_speed)
		_flagger.set_flag(&"is_climbing", false)
	# Reaching the ground
	elif vec.y > 0 && _character.test_move(_character.global_transform, _character.get_gravity_vector().normalized()):
		_flagger.set_flag(&"is_climbing", false)
	# Switches back to non-climbing
	if !_flagger.is_flag(&"is_climbing"):
		_behaviors_center.switch_behavior(&"non-climbing")
		return
	
	# Velocity
	_character.direction = _character.direction if is_zero_approx(vec.x) else int(signf(vec.x))
	_character.velocity = vec * climbing_speed
	# Animation
	_animation.speed_scale = vec.length_squared() * clampf(climbing_speed * 0.67 * delta, 0, 5)
	_animation.play(&"climb")

func _physics_process(delta: float) -> void:
	var kc := _character.move_and_collide(_character.global_velocity * delta)
	if kc:
		_character.global_velocity = _character.global_velocity.slide(kc.get_normal())
