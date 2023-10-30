class_name EventsManager

## Static class that manages game events
##
##

## Access to the signals list of the class
static var signals: SignalsManager = SignalsManager.new()


## Signals list of [EventsManager]
class SignalsManager:
	## Emitted when the game over is happening
	signal game_over


static func game_failed_process(tree: SceneTree) -> void:
	if !tree:
		assert(false, "The SceneTree is invalid!")
		return
	
	var players := PlayersManager.get_all_available_players()
	if !players:
		if Data.player_lives > 0:
			Data.add_lives(-1)
			tree.reload_current_scene()
		else:
			signals.game_over.emit()
