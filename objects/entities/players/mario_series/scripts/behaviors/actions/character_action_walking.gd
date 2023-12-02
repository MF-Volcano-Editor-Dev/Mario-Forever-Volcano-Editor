extends CharacterAction2D

const ActionCrouch := preload("./character_action_crouch.gd")
const ActionSwim := preload("./character_action_swimming.gd")

@export_category("Action Walking")
@export_group("Key")
@export var key_run: StringName = &"run"
@export_group("Physics")
## Initial walking speed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_walking_speed: float = 50
## Initial walking speed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var crouching_walking_speed: float = 50
## Acceleration
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var acceleration: float = 312.5
## Deceleration
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var deceleration: float = 312.5
## Deceleration when crouching
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var deceleration_crouching: float = 312.5
## Deceleration when crouching with arrows pressed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var deceleration_crouching_moving: float = 125
## Turning acceleration/deceleration
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var turning_aceleration: float = 1250
## Minimum of the walking speed, better to keep it 0 [br]
## [b]Note:[/b] A value greater than 0 will lead to non-stopping of the player after he finishes deceleration
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var min_speed: float
## Maximum of the walking speed in non-running state
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_walking_speed: float = 175
## Maximum of the walking speed in running state
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_running_speed: float = 350

var _crouching: bool


func _process(delta: float) -> void:
	if disabled:
		return
	
	var allowed_to_walk := is_allowed_to_walk()
	_crouching = ObjectState.is_state(character, ActionCrouch.STATE_CROUCHING)
	_walk(allowed_to_walk)
	_animation(delta)

func _physics_process(delta: float) -> void:
	if !character.is_on_wall():
		return
	_animation(delta, true) # Forced to play stopping animation if the character is colliding with a wall


#region == Walk ==
func _walk(allowed_to_walk: bool) -> void:
	if !allowed_to_walk:
		character.accelerate_local_x(get_deceleration(_crouching), 0)
		return
	
	var left_right := behavior.get_key_xy().x
	var swimming := ObjectState.is_state(character, ActionSwim.STATE_SWIMMING)
	character.max_speed = max_running_speed if is_running() && !swimming else max_walking_speed
	
	# Initial velocity.x
	if left_right && is_zero_approx(character.velocity.x):
		character.direction = left_right
		character.velocity.x = initial_walking_speed * character.direction
	# Acceleration
	if left_right * character.direction > 0:
		if _crouching: # Crouch walking
			# Do NOT adjust max_speed since it will cause the speed plunge
			character.accelerate_local_x(acceleration, crouching_walking_speed * character.max_speed_scale * character.direction)
		else: # Regular walking
			# Do NOT use accelerate_to_max_speed() in case the method would bring wrong physics
			character.accelerate_local_x(acceleration, character.max_speed * character.max_speed_scale * character.direction)
	# Turning back
	elif left_right * character.direction < 0:
		character.accelerate_local_x(turning_aceleration, 0)
		if is_zero_approx(character.velocity.x):
			character.direction *= -1
			# player.velocity.x = 6.25 * player.direction


func _animation(delta: float, forced_is_on_wall: bool = false) -> void:
	power.sprite.scale.x = character.direction
	
	if behavior.is_playing_unbreakable_animation():
		return
	
	if character.is_on_floor() && !_crouching:
		if is_zero_approx(character.velocity.x) || forced_is_on_wall:
			power.animation.play(&"RESET")
			power.animation.speed_scale = 1
		else:
			power.animation.play(&"walk")
			power.animation.speed_scale = clampf(absf(character.velocity.x) * delta * 0.67, 0, 5)
#endregion


#region == Getters ==
## Returns [code]true[/code] if the character is crouching
func is_running() -> bool:
	return Input.is_action_pressed(key_run + str(character.id))

## Returns [code]true[/code] if the [param p_character] is walkable
func is_crouching_walkable() -> bool:
	var walkable_when_crouching := bool(ProjectSettings.get_setting_with_override(&"game/control/player/walkable_when_crouching"))
	return walkable_when_crouching && ObjectState.is_state(character, ActionCrouch.STATE_CROUCHING)

## Returns [code]true[/code] if the [param p_character] is allowed to walk
func is_allowed_to_walk() -> bool:
	if !character.controllable:
		return false
	
	var crouching := ObjectState.is_state(character, ActionCrouch.STATE_CROUCHING)
	return behavior.get_key_x() && (!crouching || (crouching && is_crouching_walkable()))

## Returns deceleration
func get_deceleration(crouching: bool) -> float:
	return deceleration_crouching_moving if crouching && behavior.get_key_xy().x != 0 else deceleration_crouching if crouching else deceleration
#endregion
