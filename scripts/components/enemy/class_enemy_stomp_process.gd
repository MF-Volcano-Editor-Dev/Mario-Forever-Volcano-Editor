@tool
class_name EnemyStompProcess extends Component

## Used together with [EnemyStompable] to provide implementation for it.[br]
## [br]
## [b]Note:[/b] This only works with [EnemyStopable], so make sure the [member Component.root] is an instance of [EnemyStopable].

signal stomp_processed ## Emitted when the stomp is processed.

## Jumping speed of the character stomping onto the enemy without the jumping key being held.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var stomp_jumping_speed_min: float = 400
## Jumping speed of the character stomping onto the enemy with the jumping key being held.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var stomp_jumping_speed_max: float = 600

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if !root is EnemyStompable:
		return
	
	(root as EnemyStompable).on_stomp_succeeded.connect(_on_stomp_process)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if !get_root() is EnemyStompable:
		warnings.append("The component should work with \"root\" being an EnemyStompable instance!")
	
	return warnings


func _on_stomp_process(character: Character) -> void:
	if !is_instance_valid(character):
		return
	
	var jumping_speed: float = stomp_jumping_speed_max if character.get_input_pressed(&"jump") else stomp_jumping_speed_min
	character.jump(jumping_speed)
	
	stomp_processed.emit()
