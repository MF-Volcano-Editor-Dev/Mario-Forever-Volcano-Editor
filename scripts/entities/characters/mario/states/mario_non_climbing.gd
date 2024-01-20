extends State

@export_category("Character Non-climbing State")
@export_group("References")
@export var animated_sprite: AnimatedSprite2D
@export var shape_controller: AnimationPlayer
@export_group("Controls", "key_")
@export var key_left: StringName = &"left"
@export var key_right: StringName = &"right"
@export var key_up: StringName = &"up"
@export var key_down: StringName = &"down"
@export var key_jump: StringName = &"jump"
@export var key_run: StringName = &"run"
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
@export_group("Sounds", "sound_")
@export var sound_jumping: AudioStream = preload("res://assets/sounds/jump.wav")
@export var sound_swimming: AudioStream = preload("res://assets/sounds/swim.wav")

var _has_jumped: bool

@onready var _character: Character = root.get_parent()


func _state_process(delta: float) -> void:
	_walk()
	_jump(delta)
	_animation.call_deferred(delta) # Called at the end of a frame to make sure the animation will be correctly played if the character is walking against a wall

func _state_physics_process(_delta: float) -> void:
	_character.calculate_gravity()
	_character.move_and_slide()


func _walk() -> void:
	var lr: int = _character.get_udlr_directions(key_left, key_right, key_up, key_down).x # Acceleration
	if _character.is_in_group(&"state_completed"):
		lr = 0 # If the character has completed the level, then the input will be interfered
	# Deceleration
	if !lr:
		var dc: float = deceleration * (deceleration_scale_crouch if _character.is_in_group(&"state_crouching") else 1.0) # Deceleration
		_character.decelerate_with_friction(dc)
		return
	# Initial walking speed
	elif is_zero_approx(_character.velocality.x):
		_character.direction = lr
		_character.velocality.x = _character.direction * initial_speed
	# Walking and running
	if lr == _character.direction:
		if _character.get_input_pressed(key_run):
			_character.add_to_group(&"state_running")
		else:
			_character.remove_from_group(&"state_running")
		var crwlk: bool = bool(ProjectSettings.get_setting("game/control/player/walkable_when_crouching", false)) # Crouch-walking
		var max_spd: float = max_running_speed if _character.is_in_group(&"state_running") else max_walking_speed if !crwlk else max_walking_speed * 0.2
		_character.accelerate_local_x(acceleration, max_spd * _character.direction)
	# Turning back
	elif lr == -_character.direction:
		_character.add_to_group(&"state_turning_back")
		_character.decelerate_with_friction(walking_turning_deceleration)
		if is_zero_approx(_character.velocality.x):
			_character.direction *= -1
			_character.remove_from_group(&"state_turning_back")

func _jump(delta: float) -> void:
	if _character.is_in_group(&"state_completed"):
		return
	if _character.is_in_group(&"state_swimming"):
		return
	
	# Resets _has_jumped
	var press_jump: bool = _character.get_input_just_pressed(key_jump)
	var hold_jump: bool = _character.get_input_pressed(key_jump)
	if _has_jumped && \
		(_character.is_falling() && press_jump) || \
		(_character.is_on_floor() && !hold_jump):
			_has_jumped = false
	# Jumping
	if !_has_jumped && _character.is_on_floor() && hold_jump: # `hold_jump` detects more precise than `press_jump` here
		_has_jumped = true
		_character.jump(initial_jumping_speed)
		Sound.play_2d(sound_jumping, _character)
	# Accelerates jumping
	if _character.is_leaving_ground() && hold_jump:
		_character.jump((jumping_acceleration_dynamic if absf(_character.velocality.x) >= 10 else jumping_acceleration_static) * delta, true)


#region == Animations ==
func _animation(delta: float) -> void:
	if !animated_sprite:
		return
	
	animated_sprite.scale.x = _character.direction # Facing
	
	if animated_sprite.animation in [&"appear", &"attack"]:
		return
	
	if _character.is_on_floor():
		var real_vel: Vector2 = _character.get_real_velocity()
		if !real_vel.slide(_character.get_floor_normal()).is_zero_approx():
			animated_sprite.play(&"walk", absf(_character.velocality.x) * delta * 10)
		else:
			animated_sprite.play(&"default")
	elif _character.is_in_group(&"state_swimming"):
		animated_sprite.play(&"swim")
	elif _character.is_falling():
		animated_sprite.play(&"fall")
	else:
		animated_sprite.play(&"jump")
#endregion
