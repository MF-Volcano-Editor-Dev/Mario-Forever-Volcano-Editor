extends Component

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


var mario: Mario2D ## Fast access to [member Component.root] casted to [Mario2D]

var _pos: Vector2
var _is_climbable: bool

# These are controlled keys
var _left_right: int
var _up_down: int
var _jumped: bool
var _jumping: bool # True when holding jumping key
var _jumped_already: bool # True when not close jumping and holding jumping key, prevent from continuous jump by holding the key
var _running: bool

# These are written as variables because they are set each frame
var _jumpable_when_crouching: bool
var _walkable_when_crouching: bool
var _crouchable_in_small_suit: bool

@onready var suit: MarioSuit2D = $".."
@onready var sprite: Sprite2D = $"../Sprite2D"
@onready var animation: AnimationPlayer = $"../AnimationPlayer"
@onready var sound: Sound2D = $"../Sound2D"
@onready var aqua_root: Node = $"../AquaUpdater/AquaRoot"
@onready var aqua_behavior: Node = $"../AquaUpdater/AquaBehavior"
@onready var body: Area2D = $"../AreaBody"
@onready var head: Area2D = $"../AreaHead"


#region Main methods
func _ready() -> void:
	super()
	
	# Set root
	mario = (root as MarioSuit2D).get_player()
	
	# Animations
	animation.animation_finished.connect(_on_animation_swim_reset)
	
	# Detections
	body.area_entered.connect(_on_body_area_entered)
	body.area_exited.connect(_on_body_area_exited)
	head.area_entered.connect(_on_head_area_entered)
	head.area_exited.connect(_on_head_area_exited)


func _process(delta: float) -> void:
	# States & Controls
	_general_states_process()
	_control_state_process()
	# Movement
	if mario.state_machine.is_state(&"climbing"):
		_movement_climb_process()
	else:
		_movement_crouching_process()
		_movement_x_process(delta)
		_movement_y_process(delta)
	# Animations
	_animation_process(delta)


func _physics_process(delta: float) -> void:
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


func _general_states_process() -> void:
	# States from global settings
	_jumpable_when_crouching = ProjectSettings.get_setting("game/control/player/jumpable_when_crouching", false)
	_walkable_when_crouching = ProjectSettings.get_setting("game/control/player/walkable_when_crouching", false)
	_crouchable_in_small_suit = ProjectSettings.get_setting("game/control/player/crouchable_in_small_suit", false)


#region Controls
func _control_state_process() -> void:
	# Basic controls
	_left_right = int(Input.get_axis(_get_key_input(key_inputs.left), _get_key_input(key_inputs.right)))
	_up_down = int(Input.get_axis(_get_key_input(key_inputs.up), _get_key_input(key_inputs.down)))
	_jumped = Input.is_action_just_pressed(_get_key_input(key_inputs.jump))
	_jumping = Input.is_action_pressed(_get_key_input(key_inputs.jump))
	_running = Input.is_action_pressed(_get_key_input(key_inputs.run))
	
	# Climbing
	if _up_down < 0 && _is_climbable && !mario.state_machine.is_state(&"climbing"):
		mario.state_machine.set_state(&"climbing")
		_jumped_already = false


func _get_key_input(key_name: StringName) -> StringName:
	return key_name + StringName(str(mario.id))
#endregion


#region Movements
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
	# Acceleration
	elif _left_right * signf(mario.velocity.x) > 0:
		var crouchwalk: bool = _walkable_when_crouching && mario.state_machine.is_state(&"crouching")
		var walking_factor: float = 0.1 if crouchwalk else 1.0
		var max_speed: float = (max_running_speed if _is_running() else max_walking_speed) * walking_factor
		_accelerate(max_speed, acceleration * delta)
	# Turning back
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
	var crouching: bool = mario.state_machine.is_state(&"crouching")
	var jumpable: bool = (_jumpable_when_crouching && crouching) || !crouching
	
	_reset_jumping()
	# Underwater (Swimming)
	if underwater:
		if _jumped:
			sound.play(sound_swim)
			
			# Jumping out of water
			if underwater_jumpout:
				mario.jump(swimming_jumping_speed)
			# Swimming still
			else:
				mario.jump(swimming_speed)
			
			_jumped_already = true
			animation.stop()
			animation.play(&"swim")
		
		# Underwater peak swimming speed
		var swimming_peak: float = -abs(swimming_peak_speed)
		if !underwater_jumpout && mario.velocity.y < swimming_peak:
			mario.velocity.y = lerpf(mario.velocity.y, swimming_peak, 0.1)
	# Non-underwater (Jumping)
	else:
		if _is_jumpable() && jumpable && mario.is_on_floor():
			sound.play(sound_jump)
			mario.jump(initial_jumping_speed)
			_jumped_already = true
		
		# Jumping acceleration
		if _jumping && mario.velocity.y < 0 && !mario.is_on_floor():
			var jumping_acce: float = jumping_acceleration_dynamic if absf(mario.velocity.x) > 31.25 else jumping_acceleration_static
			mario.jump(jumping_acce * delta, true)


func _movement_climb_process() -> void:
	if mario.state_machine.is_state(&"no_climbing"):
		mario.state_machine.remove_state(&"climbing")
		return
	
	# Direction correcting
	if _left_right != 0:
		mario.direction = _left_right
	
	# Velocity
	mario.velocity = (Vector2(_left_right, _up_down).normalized() if _left_right || _up_down else Vector2.ZERO) * climbing_speed
	
	# Jumping from climbing
	if _is_jumpable() && _up_down >= 0:
		_jumped_already = true
		sound.play(sound_jump)
		mario.jump(initial_jumping_speed)
		mario.state_machine.remove_state(&"climbing")


func _movement_crouching_process() -> void:
	if mario.state_machine.is_state(&"no_crouching"):
		return
	
	var small: bool = "small" in suit.suit_features
	var crouchable: bool = (_crouchable_in_small_suit && small) || !small
	var on_floor_down: bool = _up_down > 0 && mario.is_on_floor()
	
	if on_floor_down && crouchable:
		if !mario.state_machine.is_state(&"crouching"):
			mario.state_machine.set_state(&"crouching")
			animation.play.call_deferred(&"MarioShapes/crouch")
	elif mario.state_machine.is_state(&"crouching"):
		mario.state_machine.remove_state(&"crouching")
		animation.play.call_deferred(&"MarioShapes/normal")


#region Test for Movement
func _is_decelerating() -> bool:
	var decelerating: bool = _left_right == 0
	var crouching_only: bool = mario.state_machine.is_state(&"crouching") && !_walkable_when_crouching
	return decelerating || crouching_only


func _is_running() -> bool:
	return _running


func _is_jumpable() -> bool:
	return _jumping && !_jumped_already


func _reset_jumping() -> void:
	if !_jumping && (mario.velocity.y > 0 || mario.is_on_floor()):
		_jumped_already = false
#endregion

#endregion


#region Animations
func _animation_process(delta: float) -> void:
	animation.speed_scale = 1
	sprite.scale.x = mario.direction
	
	if animation.current_animation in [&"appear", &"attack"]:
		return
	
	if mario.state_machine.is_state(&"climbing"):
		animation.play(&"climb")
		animation.speed_scale = 0.0 if mario.velocity.is_zero_approx() else 1.0
	else:
		sprite.flip_h = false
		
		if mario.is_on_floor():
			if mario.state_machine.is_state(&"crouching"):
				animation.play(&"crouch")
			elif is_zero_approx(snappedf(_pos.length_squared(), 0.01)):
				animation.play(&"RESET")
			else:
				animation.play(&"walk")
				animation.speed_scale = clampf(absf(mario.velocity.x) * delta * 0.67, 0, 5)
		elif mario.state_machine.is_state(&"underwater"):
			animation.play(&"swim")
		elif mario.velocity.y < 0:
			animation.play(&"jump")
		else:
			animation.play(&"fall")


func _on_animation_swim_reset(anim_name: StringName) -> void:
	match anim_name:
		&"swim":
			animation.advance(-0.2)
#endregion


#region Body Detections
func _on_body_area_entered(area: Area2D) -> void:
	# AreaClimbable2D
	if area is AreaClimbable2D:
		if !_is_climbable && !_jumping:
			_is_climbable = true
	
	# AreaFluid2D
	if area is AreaFluid2D:
		if area.fluid_id == &"water" && !mario.state_machine.is_state(&"underwater"):
			mario.state_machine.set_state(&"underwater")
			aqua_root.update_from_component()
			aqua_behavior.update_from_component()


func _on_body_area_exited(area: Area2D) -> void:
	# AreaClimbable2D
	if area is AreaClimbable2D:
		if _is_climbable:
			_is_climbable = false
		if mario.state_machine.is_state(&"climbing"):
			mario.state_machine.remove_state(&"climbing")
	
	# AreaFluid2D
	if area is AreaFluid2D:
		if area.fluid_id == &"water" && mario.state_machine.is_state(&"underwater"):
			mario.state_machine.remove_state(&"underwater")
			aqua_root.update_from_extracted_value()
			aqua_behavior.update_from_extracted_value()
#endregion


#region Area Detections
func _on_head_area_entered(area: Area2D) -> void:
	# AreaFluid2D
	if area is AreaFluid2D:
		if area.fluid_id == &"water" && mario.state_machine.is_state(&"underwater_jumpout"):
			mario.state_machine.remove_state(&"underwater_jumpout")


func _on_head_area_exited(area: Area2D) -> void:
	if area is AreaFluid2D:
		if area.fluid_id == &"water" && !mario.state_machine.is_state(&"underwater_jumpout"):
			mario.state_machine.set_state(&"underwater_jumpout")
#endregion

#endregion


#region Setters & Getters
func get_left_right() -> int:
	return _left_right


func get_up_down() -> int:
	return _up_down
#endregion
