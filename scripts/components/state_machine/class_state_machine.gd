@tool
@icon("res://icons/state_machine.svg")
class_name StateMachine extends Component

## A node that provides services for state management
##
## To drive the state machine, you should first add [State] under this node as the children and then specify a [member current_state]

signal state_changed ## Emitted when [member current_state] gets changed

## Current [State] of the state machine
@export var current_state: State:
	set(value):
		if Engine.is_editor_hint():
			if value.get_parent() != self:
				printerr("Cannot set the non-child state as current: %s" % get_path_to(value))
				return
			current_state = value
			return
		# Previous state calls finishing functions and emits a relevant signal
		current_state.state_exited.emit()
		current_state._state_exit()
		# Sets to new state as current
		current_state = value 
		# New state calls entering functions and emits a relevant signal
		current_state._state_enter()
		current_state.state_entered.emit()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if current_state:
		change_state(current_state.state_id)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if current_state:
		current_state._state_process(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if current_state:
		current_state._state_physics_proces(delta)


## Changes the current state to a given one that contains [member State.state_id] that is the same as [param to]
func change_state(to: StringName) -> void:
	for i in get_children():
		if !i is State:
			continue
		i = i as State # For getting coding hints
		if i.state_id == to:
			current_state = i
