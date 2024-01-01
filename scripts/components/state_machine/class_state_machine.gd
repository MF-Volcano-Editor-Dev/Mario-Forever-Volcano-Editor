@icon("res://icons/state_machine.svg")
class_name StateMachine extends Component

## Class that provides services for state management
##
## To drive the state machine, you should first add [State] under this node as the children and then specify a [member current_state]

## Current [State] of the state machine
@export var current_state: State


func _ready() -> void:
	if current_state:
		change_state(current_state.state_id)

func _process(delta: float) -> void:
	if current_state:
		current_state._state_process(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state._state_physics_proces(delta)


## Changes the current state to a given one that contains [member State.state_id] that is the same as [param to]
func change_state(to: StringName) -> void:
	for i in get_children():
		if !i is State:
			continue
		i = i as State # For getting coding hints
		if i.state_id == to:
			current_state._state_exit()
			current_state = i
			i._state_enter()
