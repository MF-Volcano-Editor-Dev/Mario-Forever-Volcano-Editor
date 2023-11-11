extends Component

## Abstract class that provides health management
##
##

## Emitted when the [member health_point] increases
signal health_point_up(amount: float)

## Emitted when the [member health_point] decreases
signal health_point_down(amount: float)

## Emitted when the [member health] is zero
signal health_zero

@export_category("Health Points")
@export_range(0, 1, 0.01, "or_greater", "hide_slider", "suffix:♥") var health: float = 1:
	set(value):
		if value > health:
			health_point_up.emit(value - health)
		elif value < health:
			health_point_down.emit(health - value)
		
		health = clampf(value, 0, INF)
		if health <= 0:
			health_zero.emit()


func add_health(amount: float) -> void:
	health += abs(amount)


func sub_health(amount: float) -> void:
	health -= abs(amount)
