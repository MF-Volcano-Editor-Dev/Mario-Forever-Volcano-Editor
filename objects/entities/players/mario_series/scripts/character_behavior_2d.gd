class_name CharacterBehavior2D extends Component

#region == References ==
@onready var _power := get_power() as CharacterPower2D
@warning_ignore("unused_private_class_variable")
@onready var _character := get_character() as CharacterEntity2D
@warning_ignore("unused_private_class_variable")
@onready var _flagger := get_flagger() as Flagger
#endregion


#region == Inner methods ==
func _action_enabled() -> void:
	process_mode = PROCESS_MODE_INHERIT

func _action_disabled() -> void:
	process_mode = PROCESS_MODE_DISABLED
#endregion

#region == Getters ==
func get_behavior() -> CharacterBehavior2D:
	return get_parent() as CharacterBehavior2D

func get_power() -> CharacterPower2D:
	return get_root() as CharacterPower2D

func get_character() -> CharacterEntity2D:
	return _power.get_parent() as CharacterEntity2D

func get_flagger() -> Flagger:
	return _character.get_flagger()
#endregion
