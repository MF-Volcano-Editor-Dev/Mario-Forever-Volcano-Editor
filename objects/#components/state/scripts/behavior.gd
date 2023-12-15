@icon("res://icons/behavior.svg")
class_name Behavior extends Component

## Abstract class that defines the behavior of a character. This is very useful when you want to
## code multiple behaviors for one entity.
##
## [b]Note:[/b] This node should be the direct child of [BehaviorsCenter2D].

@export_category("Behavior")
@export var behavior_id: StringName

@warning_ignore("unused_private_class_variable")
@onready var _behaviors_center := get_behaviors_center()


#region == Virtual triggers ==
func _action_enabled() -> void:
	process_mode = PROCESS_MODE_INHERIT

func _action_disabled() -> void:
	process_mode = PROCESS_MODE_DISABLED
#endregion


## [b]Prenote:[/b] This method should only be connected with [signal BehaviorsCenter.switched_behavior].[br]
## Detect if the passed-in id matches [member behavior_id] and switches the running behavior to this one.[br]
## [b]Note:[/b] This will disable other behaviors!
func to_switch_to_this(to_behavior: StringName) -> void:
	disabled = to_behavior == behavior_id


#region == Setget ==
func set_disabled(value: bool) -> void:
	disabled = value
	await Process.await_readiness(self)
	if value:
		_action_enabled()
	else :
		_action_disabled()

func get_behaviors_center() -> BehaviorsCenter:
	return get_root() as BehaviorsCenter
#endregion
