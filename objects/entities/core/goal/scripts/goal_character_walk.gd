class_name GoalCharacterWalk extends Component

@export_category("Goal Character Walk")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var walking_speed: float = 125

var direction: int:
	set(value):
		direction = clampi(value, -1, 1)
		if !direction:
			direction = [-1, 1].pick_random()

var _level_events := Events.get_level_events()

var _characters_to_walk: Array[CharacterEntity2D]


func _ready() -> void:
	_level_events.level_completed.connect(_on_character_completed_walking)


func add_player_to_walk(character: CharacterEntity2D) -> void:
	if character in _characters_to_walk:
		return
	_characters_to_walk.append(character)


func _on_character_completed_walking() -> void:
	for i: CharacterEntity2D in _characters_to_walk:
		# Initialization of data, called once every time the Event.level_finished is called
		i.max_speed = 0 # Unlimited max speed for better control of walking speed after completion of the level
		i.collided_wall.connect(
			func() -> void:
				_characters_to_walk.erase(i) # Remove the character from the list to make the character stop when colliding with a wall
		)
	while !disabled && !_characters_to_walk.is_empty():
		# Mini _process() with limited situations, won't be always called each frame.
		for j: CharacterEntity2D in _characters_to_walk:
			if !is_instance_valid(j): # Skips invalid character and stops completion, and clear cached character lists
				_characters_to_walk.clear()
				_level_events.level_stop_completion()
				continue
			j.direction = direction
			j.velocity.x = walking_speed
		await get_tree().process_frame
