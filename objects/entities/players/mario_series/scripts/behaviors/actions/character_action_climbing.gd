extends CharacterAction2D

const ActionJump := preload("./character_action_jumping.gd")

const STATE_CLIMBING := &"is_climbing"
const STATE_CLIMBABLE := &"is_climbable"

@export_category("Action Climbing")
@export_group("Component Links", "path_")
@export_node_path("Node") var path_action_jump: NodePath = ^"../Jump"
@export_group("Key")
@export var key_climb: StringName = &"up" ## Key climb
@export_group("Climbing")
## Moving speed when climbing
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var climbing_speed: float = 150

@onready var action_jump := get_node(path_action_jump) as ActionJump


func _process(_delta: float) -> void:
	if disabled:
		return
	
	_climb()
	_animation()


#region == Climbing ==
func _climb() -> void:
	if is_climbable():
		ObjectState.set_state(character, STATE_CLIMBING, true)
		behavior.mode = 1
	elif !ObjectState.is_state(character, STATE_CLIMBING):
		behavior.mode = 0
		return
	
	var dir := Vector2(behavior.get_key_xy()).normalized()
	character.velocity = dir * climbing_speed
	
	if character.test_move(character.global_transform, -character.up_direction):
		ObjectState.set_state(character, STATE_CLIMBING, false)
		return
	if is_climbing_jumpable():
		ObjectState.set_state(character, STATE_CLIMBING, false)
		Sound.play_sound_2d(character, action_jump.sound_jump)
		character.jump(action_jump.initial_jumping_speed)

func _animation() -> void:
	if behavior.is_playing_unbreakable_animation():
		return
	
	if ObjectState.is_state(character, STATE_CLIMBING):
		power.animation.speed_scale = 1 if character.velocity else 0
		power.animation.play(&"climb")
#endregion


#region == Getters ==
## Returns [code]true[/code] if the character is climbing and jumpable
func is_climbing_jumpable() -> bool:
	return character.controllable && Input.is_action_pressed(action_jump.key_jump + str(character.id)) && ObjectState.is_state(character, STATE_CLIMBING)

## Returns [code]true[/code] if the character is climbable in the [param area]
func is_climbable() -> bool:
	return character.controllable && !Input.is_action_pressed(action_jump.key_jump + str(character.id)) && Input.is_action_pressed(key_climb + str(character.id)) && ObjectState.is_state(character, STATE_CLIMBABLE) && !ObjectState.is_state(character, STATE_CLIMBING)
#endregion
