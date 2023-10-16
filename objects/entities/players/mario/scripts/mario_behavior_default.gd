extends Node

@export_category("Mario Behaviors")
@export_group("Override Properties")
@export var override_properties: Dictionary = {
	
}
@export_group("Key Controls")
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
@export var initial_walking_speed: float = 50

var _left_right: int
var _up_down: int
var _jumped: bool
var _jumpinig: bool
var _running: bool

@onready var mario_suit: MarioSuit2D = get_parent()
@onready var mario: Mario2D = get_parent().get_player()


func _process(delta: float) -> void:
	_control_process()
	_movement_x_process(delta)
	_movement_y_process(delta)
	_animation_process(delta)
	
	mario_suit.sprite.scale.x = mario.direction


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
func _movement_x_process(delta: float) -> void:
	if _left_right != 0 && mario.motion.x == 0:
		mario.direction = _left_right


func _movement_y_process(delta: float) -> void:
	if _jumped:
		mario.jump(600)
##endregion


##regionbegin Animations
func _animation_process(delta: float) -> void:
	if mario.is_on_floor():
		if mario.state_machine.is_state(&"crouching"):
			mario_suit.animation.play(&"Mario/crouch")
		elif is_zero_approx(snappedf(mario.motion.x, 0.01)):
			mario_suit.animation.play(&"Mario/RESET")
		else:
			mario_suit.animation.play(&"Mario/walk")
			mario_suit.animation.speed_scale = clampf(mario.motion.x * delta * 0.67, 0, 5)
	elif mario.state_machine.is_state(&"underwater"):
		pass
	elif mario.motion.y < 0:
		mario_suit.animation.play(&"Mario/jump")
	else:
		mario_suit.animation.play(&"Mario/fall")
##endregion
