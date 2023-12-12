@icon("res://icons/health_component.svg")
class_name HealthComponent extends Component

## A component that contains a health system and emits signals if the health gets changed.
##
## Health component is such one that contains a [member health] property that is monitored
## and will trigger signal emission when it increases or decreases, and a [member max_health] which
## limits the maximum of the former.[br]
## Because of the node a [Node], You can conveniently plug this node under another one that
## needs health system, and connect a signal to a method to implmenet the functions by health changes.
## Thus, you can regard the health of this component as the one of the target node.

signal health_point_up(amount: float) ## Emitted when the [member health_point] increases.
signal health_point_down(amount: float) ## Emitted when the [member health_point] decreases.
signal health_zero ## Emitted when the [member health] is zero, will be emitted together with [signal health_zero].

@export_category("Health Points")
## Current health of the component, and doesn't outnumber [member max_health]. [br]
## [b]Note:[/b] The range of this varaible is [0, [member max_health]].
@export_range(0, 1, 1, "or_greater", "hide_slider", "suffix:♥") var health: int = 1:
	set(value):
		if disabled:
			return
		
		# Signal notification of health change
		var delta_hp: int = value - health
		if delta_hp > 0:
			health_point_up.emit(delta_hp)
		elif delta_hp < 0:
			health_point_down.emit(-delta_hp)
		
		health = clampi(value, 0, max_health)
		
		# Signal notification of health being zero
		if health <= 0:
			health_zero.emit()
## Maximum of [member health]
@export_range(0, 1, 1, "or_greater", "hide_slider", "suffix:♥") var max_health: int = 1

#region Health controls
## Adds [member health] by [param amount]
func add_health(amount: int = 1) -> void:
	health += abs(amount)

## Subtracts [member health] from [param amount]
func sub_health(amount: int = 1) -> void:
	health -= abs(amount)
#endregion
