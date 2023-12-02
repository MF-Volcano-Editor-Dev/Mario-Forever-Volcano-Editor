class_name GoalCharacterWalk extends Component

@export_category("Goal Character Walk")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var walking_speed: float = 175

var direction: int:
	set(value):
		direction = clampi(value, -1, 1)
		if !direction:
			direction = [-1, 1].pick_random()
var _characters_to_walk: Array[CharacterEntity2D]


func _ready() -> void:
	EventsManager.signals.level_finished.connect(_on_character_completed_walking)


func add_player_to_walk(character: CharacterEntity2D) -> void:
	if character in _characters_to_walk:
		return
	_characters_to_walk.append(character)


func _on_character_completed_walking() -> void:
	for i: CharacterEntity2D in _characters_to_walk:
		i.collided_wall.connect(
			func() -> void:
				_characters_to_walk.erase(i)
		)
	while !disabled && !_characters_to_walk.is_empty():
		for j: CharacterEntity2D in _characters_to_walk:
			j.direction = direction
			j.velocity.x = walking_speed
		await get_tree().process_frame
