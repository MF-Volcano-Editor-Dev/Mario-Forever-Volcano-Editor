extends Node

@export_category("Mario Behaviors")
## Override the properties for [Mario2D][br]
## [b]Note:[/b] The properties should be written in NodePath-style with [String] type
@export var override_properties: Dictionary = {
	
}
@export var key_inputs: Dictionary = {
	left = &"left",
	right = &"right",
	up = &"up",
	down = &"down",
	jump = &"jump",
	run = &"run"
}
@export_group("Movement")
@export_subgroup("Walking")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var initial_walking_speed: float = 50
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var acceleration: float = 312.5
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var deceleration: float = 312.5
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var turning_aceleration: float = 1250
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var min_speed: float
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var max_walking_speed: float = 175
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var max_running_speed: float = 350
@export_subgroup("Jumping")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var initial_jumping_speed: float = 700
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var jumping_acceleration_static: float = 1000
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var jumping_acceleration_dynamic: float = 1250
@export_subgroup("Swimming")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var swimming_speed: float = 150
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var swimming_jumping_speed: float = 450
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var swimming_peak_speed: float = 150
@export_subgroup("Climbing")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var climbing_speed: float = 150
@export_group("Behavior Sounds", "sound_")
@export var sound_jump: AudioStream = preload("res://assets/sounds/jump.wav")
@export var sound_swim: AudioStream = preload("res://assets/sounds/swim.wav")

var _pos: Vector2

var _left_right: int:
	get = get_left_right
var _up_down: int:
	get = get_up_down
var _jumped: bool
var _jumping: bool
var _jumped_already: bool
var _running: bool

@onready var mario: Mario2D = get_parent().get_player()
@onready var sprite: Sprite2D = $"../Sprite2D"
@onready var animation: AnimationPlayer = $"../AnimationPlayer"
@onready var sound: Sound2D = $"../Sound2D"


func _ready() -> void:
	# Animations
	animation.animation_finished.connect(_on_animation_swim_reset)


func _process(delta: float) -> void:
	# Control
	_control_process()
	# Movement
	if mario.state_machine.is_state(&"climbing"):
		_movement_climb_process()
	else:
		_movement_x_process(delta)
		_movement_y_process(delta)
	# Animations
	_animation_process(delta)


func _physics_process(delta: float) -> void:
#region Movement
	_pos = mario.global_position
	
	if mario.state_machine.is_state(&"climbing"):
		var c := mario.move_and_collide(mario.global_velocity * delta)
		if c: mario.velocity = mario.velocity.slide(c.get_normal())
	else:
		mario.move_and_slide()
	
	mario.correct_onto_floor()
	mario.correct_on_wall_corner()
	
	_pos = mario.global_position - _pos
#endregion


#regionbegin Controls
func _control_process() -> void:
	_left_right = int(Input.get_axis(_get_key_input(key_inputs.left), _get_key_input(key_inputs.right)))
	_up_down = int(Input.get_axis(_get_key_input(key_inputs.up), _get_key_input(key_inputs.down)))
	_jumped = Input.is_action_just_pressed(_get_key_input(key_inputs.jump))
	_jumping = Input.is_action_pressed(_get_key_input(key_inputs.jump))
	_running = Input.is_action_pressed(_get_key_input(key_inputs.run))


func _get_key_input(key_name: StringName) -> StringName:
	return key_name + StringName(str(mario.id))
#endregion


#regionbegin Movements
func _accelerate(to: float, acce_with_delta: float) -> void:
	mario.velocity.x = move_toward(mario.velocity.x, to * mario.direction, acce_with_delta)

func _movement_x_process(delta: float) -> void:
	if mario.state_machine.is_state(&"no_walking"):
		return
	
	# Deceleration
	if _is_decelerating():
		_accelerate(min_speed, deceleration * delta)
		return
	
	# Initial speed
	if _left_right != 0 && mario.velocity.x == 0:
		mario.direction = _left_right
		mario.velocity.x = initial_walking_speed * mario.direction
	elif _left_right * signf(mario.velocity.x) > 0:
		var max_speed: float = max_running_speed if _is_running() else max_walking_speed
		_accelerate(max_speed, acceleration * delta)
	elif _left_right * signf(mario.velocity.x) < 0:
		_accelerate(0, turning_aceleration * delta)
		mario.state_machine.set_state(&"turning")
		
		if is_zero_approx(mario.velocity.x):
			mario.direction *= -1
			mario.state_machine.remove_state(&"turning")


func _movement_y_process(delta: float) -> void:
	if mario.state_machine.is_state(&"no_jumping"):
		return
	
	var underwater: bool = mario.state_machine.is_state(&"underwater")
	var underwater_jumpout: bool = mario.state_machine.is_state(&"underwater_jumpout")
	
	_test_reset_jumping()
	if _is_jumpable():
		# Underwater
		if underwater:
			sound.play(sound_swim)
			# Jumping out of water
			if underwater_jumpout:
				mario.jump(swimming_jumping_speed)
			# Swimming
			else:
				mario.jump(swimming_speed)
			_jumped_already = true
		elif _jumped && mario.is_on_floor():
			sound.play(sound_jump)
			mario.jump(initial_jumping_speed)
			_jumped_already = true
	
	# Jumping acceleration
	if _jumping && mario.is_leaving_ground() && !mario.is_on_floor():
		var jumping_acce: float = jumping_acceleration_dynamic if absf(mario.velocity.x) > 31.25 else jumping_acceleration_static
		mario.jump(jumping_acce * delta, true)
	
	# Underwater peak swimming speed
	var up_velocity: Vector2 = mario.velocity.project(mario.up_direction)
	if underwater && up_velocity.length_squared() > swimming_peak_speed ** 2:
		mario.velocity = Vec2D.get_projection_limit(mario.velocity, up_velocity.normalized(), swimming_peak_speed)


func _movement_climb_process() -> void:
	if mario.state_machine.is_state(&"no_climbing"):
		mario.state_machine.remove_state(&"climbing")
		return
	
	if _left_right != 0:
		mario.direction = _left_right
	
	mario.velocity = (Vector2(_left_right, _up_down).normalized() if _left_right || _up_down else Vector2.ZERO) * climbing_speed
	
	_jumped_already = false
	if _jumped:
		_jumped_already = true
		sound.play(sound_jump)
		mario.jump(initial_jumping_speed)
		mario.state_machine.remove_state(&"climbing")


#region Test for Movement
func _is_decelerating() -> bool:
	return _left_right == 0 || mario.state_machine.is_state(&"crouching")


func _is_running() -> bool:
	return _running


func _is_jumpable() -> bool:
	return _jumped && !_jumped_already


func _test_reset_jumping() -> void:
	if !_jumping && _jumped_already: _jumped_already = false
#endregion

#endregion


#regionbegin Animations
func _animation_process(delta: float) -> void:
	animation.speed_scale = 1
	sprite.scale.x = mario.direction
	
	if mario.state_machine.is_state(&"climbing"):
		animation.play(&"Mario/climb")
		animation.speed_scale = 0.0 if mario.velocity.is_zero_approx() else 1.0
	else:
		sprite.flip_h = false
		
		if mario.is_on_floor():
			if mario.state_machine.is_state(&"crouching"):
				animation.play(&"Mario/crouch")
			elif is_zero_approx(snappedf(_pos.length_squared(), 0.01)):
				animation.play(&"Mario/RESET")
			else:
				animation.play(&"Mario/walk")
				animation.speed_scale = clampf(absf(mario.velocity.x) * delta * 0.67, 0, 5)
		elif mario.state_machine.is_state(&"underwater"):
			animation.play(&"Mario/swim")
		elif mario.velocity.y < 0:
			animation.play(&"Mario/jump")
		else:
			animation.play(&"Mario/fall")


func _on_animation_swim_reset(anim_name: StringName) -> void:
	match anim_name:
		&"Mario/swim":
			animation.advance(-0.2)
#endregion


#regionbegin Setters & Getters
func get_left_right() -> int:
	return _left_right


func get_up_down() -> int:
	return _up_down
#endregion
