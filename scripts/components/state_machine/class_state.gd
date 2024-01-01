@icon("res://icons/state.svg")
class_name State extends Component

## Abstract class used as the child of [StateMachine] to provide implementation of each state.
##
## Before you are going to implement a state, you need to instantiate and add a [StateMachine] first.[br]
## The [State] serves the state machine and provides realization of each state, so this is abstract and needs overriding to completely get the state machine system run as expected.[br]
## [State] also offers special virtual methods beginning with [code]_state_[/code]. [method _state_enter] and [method _state_exit] are called respectively at the moment the state becomes current one, or the state goes back to non-current one.

## Id of the state.[br]
## When [method StateMachine.change_state] is called, this property will get into usage to match if the given [param to] matches this. If [code]true[/code], this state will become current state.
@export var state_id: StringName


## [code]virtual:[/code] Called when the state becomes current. 
func _state_enter() -> void: pass

## [code]virtual:[/code] Called when the state becomes non-current.
func _state_exit() -> void: pass

## [code]virtual[/code] Called when the state [u]is current[/u] and the state machine's [method Node._process] gets called.
func _state_process(_delta: float) -> void: pass

## [code]virtual[/code] Called when the state [u]is current[/u] and the state machine's [method Node._physics_process] gets called.
func _state_physics_proces(_delta: float) -> void: pass
