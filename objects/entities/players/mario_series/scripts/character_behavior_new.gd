class_name CharacterBehavior2D extends Component

## Class that manages a series of [CharacterBehaviorAction2D] as its children
##
##

@export_category("Actions")
@export_group("Animations", "animations_")
@export var animations_unbreakable: Array[StringName] = [&"appear", &"attack"]
@export_group("Key Inputs", "key")
@export var key_up: StringName = &"up" ## Key up
@export var key_down: StringName = &"down" ## Key down
@export var key_left: StringName = &"left" ## Key left
@export var key_right: StringName = &"right" ## Key right

var _actions: Dictionary
var _disabled: Array[bool]

@onready var power := get_parent() as CharacterPower2D
@onready var character := power.get_parent() as CharacterEntity2D


func _ready() -> void:
	for i: Node in get_children():
		var action := i as CharacterAction2D
		if !action || action.action_name.is_empty():
			continue
		
		_actions.merge({action.action_name: action}, true)
		_disabled.append(action.disabled)


## Makes [param actions] process and turn off other ones
func switch_to_actions_only(actions: Array[StringName]) -> void:
	for i: Node in get_children():
		if !i is CharacterAction2D:
			continue
		elif !i.action_name in actions:
			i.process_mode = PROCESS_MODE_DISABLED
			continue
		i.process_mode = process_mode


## Disables all actions with [param value]
func disables(value: bool) -> void:
	var actions := get_children()
	for i in actions.size():
		var action := actions[i] as CharacterAction2D
		if !action is CharacterAction2D:
			continue
		
		if value:
			action.disabled = true
		else:
			action.disabled = _disabled[i]


#region == Setgets ==
func set_disabled(value: bool) -> void:
	super(value)
	disables(value)

## Returns the [CharacterBehaviorAction2D] by given [param action].[br]
## If the certain action is unavailable to get access to, an error will be thrown and a [code]null[/code] will be returned
func get_action(action: StringName) -> CharacterAction2D:
	if action in _actions:
		return _actions[action]
	else:
		printerr("No such an action implemented!")
		return null

## Returns the x direction of held keys
func get_key_x() -> int:
	return int(Input.get_axis(key_left + str(character.id), key_right + str(character.id)))

## Returns the y direction of held keys
func get_key_y() -> int:
	return int(Input.get_axis(key_up + str(character.id), key_down + str(character.id)))

## Returns the direction of held keys, ranging from (-1, -1) to (1, 1)
func get_key_xy() -> Vector2i:
	return Vector2i(get_key_x(), get_key_y())


## Returns [code]true[/code] if the animation player is playing an unbreakable animation
func is_playing_unbreakable_animation() -> bool:
	return power.animation.current_animation in animations_unbreakable
#endregion
