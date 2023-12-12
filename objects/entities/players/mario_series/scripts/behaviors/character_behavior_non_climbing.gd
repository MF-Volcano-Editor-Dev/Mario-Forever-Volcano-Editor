extends CharacterBehavior2D

@export_category("Character Action Non Climbing")
@export_group("State")
@export var is_small: bool
@export_group("Keys")
@export var key_up: StringName = &"up"
@export var key_down: StringName = &"down"
@export var key_left: StringName = &"left"
@export var key_right: StringName = &"right"
@export var key_to_climb: StringName = &"up"
@export var key_jump: StringName = &"jump"
@export var key_swim: StringName = &"jump"
@export var key_run: StringName = &"run"
@export_group("Shapes")
@export_subgroup("Body")
@export var shape_normal: CharacterShape2D = preload("res://objects/entities/players/mario_series/resources/shapes/character_shape_mario_small.tres")
@export var shape_crouch: CharacterShape2D = preload("res://objects/entities/players/mario_series/resources/shapes/character_shape_mario_small.tres")
@export_subgroup("Head")
@export var head_normal: CharacterShape2D = preload("res://objects/entities/players/mario_series/resources/shapes/character_head_mario_small.tres")
@export var head_crouch: CharacterShape2D = preload("res://objects/entities/players/mario_series/resources/shapes/character_head_mario_small.tres")
@export_group("Physics")
@export_subgroup("Gravity")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:x") var gravity_scale: float = 1
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_falling_speed: float = 500
@export_subgroup("Walk")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_speed: float = 50
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var acceleration: float = 312.5
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var deceleration: float = 312.5
@export_range(0, 5, 0.001, "suffix:x") var deceleration_scale_crouching: float = 1.5
@export_range(0, 5, 0.001, "suffix:x") var deceleration_scale_crouching_sliding: float = 0.6
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var turning_deceleration: float = 1250
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_walking_speed: float = 175
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_running_speed: float = 350
@export_range(0, 5, 0.001, "suffix:x") var max_walking_speed_crouching_scale: float = 0.2
@export_subgroup("Jump")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_jumping_speed: float = 700
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var jumping_acceleration_static: float = 1000
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var jumping_acceleration_dynamic: float = 1250
@export_subgroup("Swim")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var swimming_speed: float = 150
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var swimming_jumping_speed: float = 450
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var swimming_peak_speed: float = 150
@export_group("Sounds", "sound_")
@export var sound_jump: AudioStream = preload("res://assets/sounds/jump.wav")
@export var sound_swim: AudioStream = preload("res://assets/sounds/swim.wav")

#region == Flags ==
var _key_xy: Vector2i # Directions of arrow keys

var _has_jumped: bool

var _running: bool # Is running
var _crouching: bool # On crouching
var _swimming: bool # On swimming
var _swimming_out: bool # On swimming jumping out of the water
var _climbable: bool # Is climable
var _climbing: bool # Is climbing

@onready var _jumpable_when_crouching := ProjectSettings.get_setting("game/control/player/walkable_when_crouching") as bool
@onready var _able_crouch_walking := ProjectSettings.get_setting("game/control/player/walkable_when_crouching") as bool
@onready var _crouchable_in_small := ProjectSettings.get_setting("game/control/player/crouchable_in_small_suit") as bool
#endregion

#region == Data ==
var _pos_delta: Vector2
#endregion

@onready var _sprite := get_power().get_sprite() as Node2D
@onready var _animation := get_power().get_animation() as AnimationPlayer


func _ready() -> void:
	_flagger.flag_set.connect(_on_character_flagger_changed)
	_animation.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	_character.set_key_xy(key_up, key_down, key_left, key_right)
	_key_xy = _character.get_key_xy()
	
	_crouch()
	_walk()
	_jump(delta)
	_swim(delta)
	_anim(delta)

func _physics_process(_delta: float) -> void:
	if disabled:
		return
	
	_pos_delta = _character.global_position
	_character.gravity_scale = gravity_scale
	_character.max_falling_speed = max_falling_speed
	if _character.get_warp_direction() == CharacterEntity2D.WarpDir.NONE:
		_character.move_and_slide()
		_character.correct_onto_floor()
		_character.correct_on_wall_corner()
	_pos_delta = _character.global_position - _pos_delta


#region == Movements ==
func _crouch() -> void:
	_flagger.set_flag(&"is_crouching", _character.controllable && _character.is_on_floor() && _character.get_key_y() > 0 && (!is_small || (is_small && _crouchable_in_small)))

func _walk() -> void:
	_flagger.set_flag(&"is_running", _character.is_action_pressed(key_run)) # Sets running flag
	
	if !is_walkable():
		_character.decelerate_with_friction(get_deceleration())
		return
	
	# TBD: Currently, the max_speed underwater is the same to max_walking_speed
	# and since the difficulty of introducing speed_scale for velocity.x, it's
	# not supported, either, to limit the max speed in different fluid
	# NOTE: However, you can override the relative pieces of code of fluid
	# to make the speed affection.
	var max_speed: float = max_running_speed if _running && !_swimming else max_walking_speed
	
	if _key_xy.x && is_zero_approx(_character.velocity.x): # Initial speed
		_character.direction = _key_xy.x
		_character.velocity.x = initial_speed * _character.direction
	elif _key_xy.x == _character.direction: # Acceleration
		var accelerate_to := _character.direction * max_speed * (max_walking_speed_crouching_scale if _crouching && _able_crouch_walking else 1.0)
		_character.accelerate_local_x(acceleration, accelerate_to)
	elif _key_xy.x == -_character.direction:
		_character.decelerate_with_friction(turning_deceleration)
		if is_zero_approx(_character.velocity.x):
			_character.direction *= -1

func _jump(delta: float) -> void:
	if !_character.controllable || _swimming || (_crouching && !_jumpable_when_crouching):
		return
	
	var on_floor := _character.is_on_floor()
	var is_falling := _character.is_falling()
	var jumping := _character.is_action_pressed(key_jump)
	if _has_jumped && !jumping && (on_floor || is_falling):
		_has_jumped = false
	
	_flagger.set_flag(&"is_jumping", jumping)
	
	var jumpable := !_has_jumped && jumping
	if on_floor && jumpable:
		Sound.play_sound_2d(_character, sound_jump)
		_character.jump(initial_jumping_speed)
		return
	var speed := absf(_character.velocity.x)
	if _character.is_leaving_ground() && jumping:
		_character.jump((jumping_acceleration_dynamic if speed >= 62.5 else jumping_acceleration_static) * delta, true)

func _swim(delta: float) -> void:
	if !_character.controllable || !_swimming:
		return
	
	var swim := _character.is_action_just_pressed(key_swim)
	if swim:
		Sound.play_sound_2d(_character, sound_swim)
		_character.jump(swimming_jumping_speed if _swimming_out else swimming_speed)
	
	var peak_speed: float = -absf(swimming_peak_speed)
	if _swimming && !_swimming_out && _character.velocity.y < peak_speed:
		_character.velocity.y = lerpf(_character.velocity.y, peak_speed, 8 * delta)
#endregion

#region == Animations ==
func _anim(delta: float) -> void:
	const UNBREAKABLES: Array[StringName] = [&"appear", &"attack"]
	
	_animation.speed_scale = 1
	if _sprite.scale.x != _character.direction:
		_sprite.scale.x = _character.direction
	
	if _animation.current_animation in UNBREAKABLES:
		return
	
	var speed := _character.velocity.x
	if _character.is_on_floor():
		if _crouching:
			_animation.play(&"crouch")
		elif _pos_delta.is_zero_approx():
			_animation.play(&"RESET")
		else:
			_animation.play(&"walk")
			_animation.speed_scale = clampf(absf(speed) * delta * 0.67, 0, 5)
	elif _swimming:
		_animation.play(&"swim")
	elif _character.is_falling():
		_animation.play(&"fall")
	else:
		_animation.play(&"jump")

func _on_animation_finished(anim: StringName) -> void:
	match anim:
		&"swim":
			_animation.advance(-0.2)
		&"attack":
			_animation.play(&"RESET")
#endregion

#region == Flag changing ==
func _on_character_flagger_changed(flag: StringName, value: bool) -> void:
	match flag:
		&"is_running":
			_running = value
		&"is_climbing":
			_climbing = value
			process_mode = PROCESS_MODE_INHERIT if _climbing else PROCESS_MODE_DISABLED
		&"is_climbable":
			_climbable = value
		&"is_crouching":
			_crouching = value
		&"is_swimming":
			_swimming = value
		&"is_swimming_out":
			_swimming_out = value

func _on_crouching(value: bool) -> void:
	_character.update_body_collision_shapes(shape_crouch if value else shape_normal)
	_character.update_head_collision_shape(head_crouch if value else head_normal)
#endregion

#region == Getters ==
func is_walkable() -> bool:
	var crouch_walkable := _crouching && _able_crouch_walking
	return _character.controllable && _key_xy.x && (!_crouching || crouch_walkable)

func get_deceleration() -> float:
	var dec_scale: float = 1.0 if !_crouching else deceleration_scale_crouching if !_key_xy.x else deceleration_scale_crouching_sliding
	return deceleration * dec_scale
#endregion
