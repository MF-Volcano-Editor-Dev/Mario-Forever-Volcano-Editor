extends Component


func _ready() -> void:
	if !_root is LevelTimer:
		return
	
	_root.timer_over.connect(_on_time_up_killed_all_players)


## Kills all players
func _on_time_up_killed_all_players() -> void:
	if disabled:
		return
	
	var players := await CharactersManager2D.get_characters_getter().get_characters()
	for i: CharacterEntity2D in players:
		i.die()
