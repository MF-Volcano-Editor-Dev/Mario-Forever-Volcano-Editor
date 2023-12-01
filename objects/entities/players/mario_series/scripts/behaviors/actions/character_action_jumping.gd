extends CharacterAction2D

const ActionSwim := preload("./character_action_swimming.gd")
const ActionCrouch := preload("./character_action_crouch.gd")

const STATE_IS_JUMPED := &"is_jumped"

@export_category("Action Jumping")
@export_group("Key")
@export var key_jump: StringName = &"jump" ## Key jump
@export_group("Component Links", "path_")
@export_node_path("Node") var path_action_crouch: NodePath = ^"../Crouch"
@export_subgroup("Jumping")
## Initial jumping speed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_jumping_speed: float = 700
## Jumping acceleration when the jumping key is held and the player IS NOT walking
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var jumping_acceleration_static: float = 1000
## Jumping acceleration when the jumping key is held and the player IS walking
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var jumping_acceleration_dynamic: float = 1250
@export_group("Sounds", "sound_")
## Jumping sound
@export var sound_jump: AudioStream = preload("res://assets/sounds/jump.wav")

@onready var action_crouch := get_node(path_action_crouch) as ActionCrouch


func _process(delta: float) -> void:
	if disabled:
		return
	_jump(delta)
	_animation()


#region == Jumping ==
func _jump(delta: float) -> void:
	if ObjectState.is_state(character, &"is_swimming"):
		return
	
	if is_jumpable():
		Sound.play_sound_2d(character, sound_jump)
		character.jump(initial_jumping_speed)
		_make_jumped(character)
	
	if character.is_leaving_ground() && is_jumping():
		character.jump((jumping_acceleration_dynamic if absf(character.velocity.x) > 50 else jumping_acceleration_static) * delta, true)

func _make_jumped(p_character: CharacterEntity2D) -> void:
	ObjectState.set_state(p_character, STATE_IS_JUMPED, true)

func _animation() -> void:
	if behavior.is_playing_unbreakable_animation():
		return
	
	if !character.is_on_floor() && !ObjectState.is_state(character, ActionSwim.STATE_SWIMMING):
		power.animation.speed_scale = 1
		if character.is_leaving_ground():
			power.animation.play(&"jump")
		elif character.is_falling():
			power.animation.play(&"fall")
#endregion


#region == Getters ==
## Returns [code]true[/code] if the player is holding jumping key
func is_jumping() -> bool:
	return Input.is_action_pressed(key_jump + str(character.id))

## Returns [code]true[/code] if the [param character] is jumpable
func is_jumpable() -> bool:
	if !character.controllable:
		return false
	
	var jumping_held := is_jumping()
	var on_floor := character.is_on_floor()
	var on_falling := character.is_falling()
	var on_crouching := ObjectState.is_state(character, ActionCrouch.STATE_CROUCHING)
	var jumpable_when_crouching := bool(ProjectSettings.get_setting_with_override(&"game/control/player/jumpable_when_crouching"))
	var crouch_jumpable := (!on_crouching || (on_crouching && jumpable_when_crouching))
	
	if !jumping_held && (on_floor || on_falling):
		ObjectState.set_state(character, STATE_IS_JUMPED, false)
	
	return !ObjectState.is_state(character, &"is_swimming") && !ObjectState.is_state(character, STATE_IS_JUMPED) && jumping_held && on_floor && crouch_jumpable

#endregion
