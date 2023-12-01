extends CharacterAction2D

const STATE_CROUCHING := &"is_crouching"

@export_category("Action Crouch")
@export_group("Shape Controls")
@export_subgroup("Normal")
@export var normal_body_shape_scale: Vector2 = Vector2(1, 1)
@export var normal_body_shape_position: Vector2 = Vector2(0, 2)
@export_subgroup("Crouch")
@export var crouch_body_shape_scale: Vector2 = Vector2(1, 1)
@export var crouch_body_shape_position: Vector2 = Vector2(0, 2)
@export_subgroup("Head")
@export var normal_head_position: Vector2 = Vector2(0, -13)
@export var crouch_head_position: Vector2 = Vector2(0, -13)


func _process(_delta: float) -> void:
	if disabled:
		return
	
	var crouching := test_crouching()
	_crouch(crouching)
	_animation(crouching)


#region == Crouch ==
func _crouch(crouching: bool) -> void:
	var shapes: Array[CollisionShape2D] = [character.shape, character.body_shape]
	var shape_head := character.head_shape
	
	# Changing the transform of shape
	if crouching:
		shape_head.position = crouch_head_position
		for i: CollisionShape2D in shapes:
			i.scale = crouch_body_shape_scale
			i.position = crouch_body_shape_position
	else:
		shape_head.position = normal_head_position
		for j: CollisionShape2D in shapes:
			j.scale = normal_body_shape_scale
			j.position = normal_body_shape_position

func _animation(crouching: bool) -> void:
	if behavior.is_playing_unbreakable_animation():
		return
	
	if crouching:
		power.animation.speed_scale = 1
		power.animation.play(&"crouch")
#endregion


#region == Getters ==
## Returns [code]true[/code] if the character is crouching
func is_crouching() -> bool:
	return ObjectState.is_state(character, STATE_CROUCHING)

## Test if the character is able to crouch and returns [code]true[/code] if the character is and set to crouching state
func test_crouching() -> bool:
	if !character.controllable:
		ObjectState.set_state(character, STATE_CROUCHING, false)
	else:
		var small_crouchable := bool(ProjectSettings.get_setting_with_override(&"game/control/player/crouchable_in_small_suit"))
		var crouchable := behavior.get_key_y() > 0 && character.is_on_floor() && (!power.is_small || (power.is_small && small_crouchable))
		ObjectState.set_state(character, STATE_CROUCHING, crouchable)
	return is_crouching()
#endregion
