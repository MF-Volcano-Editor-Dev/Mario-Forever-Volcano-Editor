extends Component

## Kills all players
func time_up_kill_all_players() -> void:
	if disabled:
		return
	
	var players := await CharactersManager2D.get_characters_getter().get_characters(get_tree())
	for i: CharacterEntity2D in players:
		i.die()
