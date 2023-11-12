extends Node

@export_category("Timer Up Players Killer")
@export var killer_disabled: bool


## Kills all players
func time_up_kill_all_players() -> void:
	if killer_disabled:
		return
	
	for i: EntityPlayer2D in PlayersManager.get_all_available_players():
		i.die()
