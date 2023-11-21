extends Component

## Kills all players
func time_up_kill_all_players() -> void:
	if disabled:
		return
	
	for i: EntityPlayer2D in PlayersManager.get_all_available_players():
		i.die()
