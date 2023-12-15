class_name CharacterBehavior2D extends Behavior

## Abstract class that defines the behavior of a character
##
## [b]Note:[/b] This node should be the direct child of [CharacterBehaviorsCenter2D].

@export_category("Character Behavior")

#region == References ==
@warning_ignore("unused_private_class_variable")
@onready var _power := get_power()
@warning_ignore("unused_private_class_variable")
@onready var _character := get_character()
@warning_ignore("unused_private_class_variable")
@onready var _flagger := get_flagger()
#endregion


#region == Getters ==
func get_power() -> CharacterPower2D:
	return get_behaviors_center().get_root() as CharacterPower2D

func get_character() -> CharacterEntity2D:
	return get_power().get_parent() as CharacterEntity2D

func get_flagger() -> Flagger:
	return get_character().get_flagger() as Flagger
#endregion 
