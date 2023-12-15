@icon("res://icons/behaviors_center.svg")
class_name BehaviorsCenter extends Component

## Class that manages the [Behavior] under the node. This is very useful when you want to
## code multiple behaviors for one entity.
##
## [b]Note:[/b] All [Behavior]s should work as the children of
## this node

@export_category("Behaviors Center")
@export var behaviors_center_id: StringName ## Id of the behaviors center

signal switched_behavior(to_behavior: StringName) ## Emitted when a [method switch_behavior] is called
signal switched_behaviors_center(to_behaviors_center: StringName) ## Emitted when a [method switch_behavior] is called

#region == Virtual triggers ==
func _action_enabled() -> void:
	process_mode = PROCESS_MODE_INHERIT

func _action_disabled() -> void:
	process_mode = PROCESS_MODE_DISABLED
#endregion

## Switches the behavior to one with certain id given by [param to_behavior].
func switch_behavior(from_behavior: Behavior, to_behavior: StringName) -> void:
	from_behavior._action_disabled()
	switched_behavior.emit(to_behavior)

## Switches the behaviors center to one with certain id given by [param to_behaviors_center].
func switch_behaviors_center(from_behaviors_center: BehaviorsCenter, to_behaviors_center: StringName) -> void:
	from_behaviors_center._action_disabled()
	switched_behaviors_center.emit(to_behaviors_center)

## [b]Prenote:[/b] This method should only be connected with [signal switched_behaviors_center].[br]
## Detect if the passed-in id matches [member behaviors_center_id] and switches the running behaviors center to this one.[br]
## [b]Note:[/b] This will disable other behaviors centers!
func to_switch_to_this(to_behaviors_center: StringName) -> void:
	disabled = to_behaviors_center == behaviors_center_id


func set_disabled(value: bool) -> void:
	disabled = value
	await Process.await_readiness(self)
	if disabled:
		_action_enabled()
	else:
		_action_disabled()
