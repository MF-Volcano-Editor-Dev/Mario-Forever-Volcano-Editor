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
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var max_walking_speed: float = 262.5
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var max_running_speed: float = 375

var _left_right: int
var _up_down: int
var _jumped: bool
var _jumpinig: bool
var _running: bool

@onready var mario: Mario2D = get_parent().get_player()
@onready var sprite: Sprite2D = $"../Sprite2D"
@onready var animation: AnimationPlayer = $"../AnimationPlayer"


func _ready() -> void:
	# Animations
	animation.animation_finished.connect(_on_animation_swim_reset)

func _process(delta: float) -> void:
	# Control
	_control_process()
	# Movement
	_movement_x_process(delta)
	_movement_y_process(delta)
	# Animations
	_animation_process(delta)


func _physics_process(delta: float) -> void:
	mario.move_and_slide()


##regionbegin Controls
func _control_process() -> void:
	_left_right = int(Input.get_axis(_get_key_input(key_inputs.left), _get_key_input(key_inputs.right)))
	_up_down = int(Input.get_axis(_get_key_input(key_inputs.up), _get_key_input(key_inputs.down)))
	_jumped = Input.is_action_just_pressed(_get_key_input(key_inputs.jump))
	_jumpinig = Input.is_action_pressed(_get_key_input(key_inputs.jump))
	_running = Input.is_action_pressed(_get_key_input(key_inputs.run))


func _get_key_input(key_name: StringName) -> StringName:
	return key_name + StringName(str(mario.id))
##endregion


##regionbegin Movements
func _accelerate(to: float, acce_with_delta: float) -> void:
	mario.motion.x = move_toward(mario.motion.x, to * mario.direction, acce_with_delta)

func _movement_x_process(delta: float) -> void:
	# Deceleration
	if _is_decelerating():
		_accelerate(0, deceleration * delta)
		return
	
	# Initial speed
	if _left_right != 0 && mario.motion.x == 0:
		mario.direction = _left_right
		mario.motion.x = initial_walking_speed * mario.direction
	elif _left_right * signf(mario.motion.x) > 0:
		var max_speed: float = max_running_speed if _is_running() else max_walking_speed
		_accelerate(max_speed, acceleration * delta)
	elif _left_right * signf(mario.motion.x) < 0:
		_accelerate(0, turning_aceleration * delta)
		mario.state_machine.set_state(&"turning")
		
		if is_zero_approx(mario.motion.x):
			mario.direction *= -1
			mario.state_machine.remove_state(&"turning")


func _movement_y_process(delta: float) -> void:
	if _jumped:
		mario.jump(600)


##region Test for Movement
func _is_decelerating() -> bool:
	return _left_right == 0 || mario.state_machine.is_state(&"crouching")

func _is_running() -> bool:
	return _running
##endregion

##endregion


##regionbegin Animations
func _animation_process(delta: float) -> void:
	animation.speed_scale = 1
	sprite.scale.x = mario.direction
	
	if mario.state_machine.is_state(&"climbing"):
		animation.play(&"Mario/climb")
	elif mario.is_on_floor():
		if mario.state_machine.is_state(&"crouching"):
			animation.play(&"Mario/crouch")
		elif is_zero_approx(snappedf(mario.motion.x, 0.01)):
			animation.play(&"Mario/RESET")
		else:
			animation.play(&"Mario/walk")
			animation.speed_scale = clampf(absf(mario.motion.x) * delta * 0.67, 0, 5)
	elif mario.state_machine.is_state(&"underwater"):
		animation.play(&"Mario/swim")
	elif mario.motion.y < 0:
		animation.play(&"Mario/jump")
	else:
		animation.play(&"Mario/fall")


func _on_animation_swim_reset(anim_name: StringName) -> void:
	match anim_name:
		&"Mario/swim":
			animation.advance(-0.2)
##endregion
