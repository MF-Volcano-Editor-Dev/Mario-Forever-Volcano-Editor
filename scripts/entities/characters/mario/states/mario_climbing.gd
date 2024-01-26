extends State

## 
##
## If you want to customize the behavior based on this script, please override the related method(s).

const _NonClimbing: Script = preload("./mario_non_climbing.gd")

@export_category("Character Climbing State")
@export_group("References")
@export var state_non_climbing: State
@export_group("Physics")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var climbing_speed: float = 100

var _dir: Vector2
var _animation_count: float

@onready var _character: Mario = root.get_parent()
@onready var _state_non_climbing: _NonClimbing = state_non_climbing as _NonClimbing


func _state_entered() -> void:
	_character.velocality = Vector2.ZERO

func _state_exited() -> void:
	if !_state_non_climbing:
		return
	if !_state_non_climbing.animated_sprite:
		return
	_state_non_climbing.animated_sprite.scale.x = _character.direction

func _state_process(delta: float) -> void:
	_climb()
	_animation(delta)
	_non_climbing_check()

func _state_physics_process(delta: float) -> void:
	var kc: KinematicCollision2D = _character.move_and_collide(_character.velocity * delta)
	if kc && kc.get_collider():
		_character.velocity = _character.velocity.slide(kc.get_normal())
		# Climbing down onto the ground means going back to non-climbing state
		if kc.get_normal().dot(_character.up_direction) > 0:
			_character.remove_from_group(&"state_climbing")


func _non_climbing_check() -> void:
	if !_character.is_in_group(&"state_climbing"):
		_state_machine.change_state(&"non_climbing")


func _climb() -> void:
	if !_state_non_climbing:
		return
	_dir = Vector2(_character.get_udlr_directions(
		_state_non_climbing.key_left, 
		_state_non_climbing.key_right, 
		_state_non_climbing.key_up, 
		_state_non_climbing.key_down
	))
	if !_dir.is_zero_approx():
		_dir = _dir.normalized()
		if _dir.x: # Sets the character's direction by pressing left or right
			_character.direction = int(roundf(_dir.x)) 
	_character.velocality = _dir * climbing_speed
	
	# Jump to quit the state of climbing
	if _character.get_input_just_pressed(_state_non_climbing.key_jump):
		_state_non_climbing._has_jumped = true
		_character.jump(_state_non_climbing.initial_jumping_speed)
		_character.remove_from_group(&"state_climbing")
		Sound.play_2d(_state_non_climbing.sound_jumping, _character)

func _animation(delta: float) -> void:
	if !_state_non_climbing:
		return
	if !_state_non_climbing.animated_sprite:
		return
	if _state_non_climbing.animated_sprite.animation in [&"appear", &"attack"]:
		return
	
	_state_non_climbing.animated_sprite.play(&"climb")
	
	if _dir.is_zero_approx():
		return
	
	_animation_count += delta
	if _animation_count > 0.1: # 10 seconds
		_animation_count = 0
		_state_non_climbing.animated_sprite.scale.x *= -1 # Flips the sprite horizontally
