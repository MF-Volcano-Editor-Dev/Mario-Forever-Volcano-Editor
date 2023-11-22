class_name EventsManager

## Static class that manages game events
##
##

## Access to the signals list of the class
static var signals: SignalsManager = SignalsManager.new()


## Signals list of [EventsManager]
class SignalsManager:
	## Emitted when all players are dead
	signal players_all_dead
	
	## Emitted when the game over is happening
	signal game_over
	
	## Emitted when the level is finished
	signal level_finished
	
	## Emitted when the level is done finishing
	signal level_done_finishing


## Called to check if all players are dead, and emit [signal EventsManager.SignalsManager.players_all_dead]
## if yes [br]
## This is called when a player starts death process
static func player_all_death_detect() -> void:
	if PlayersManager.get_all_available_players().is_empty():
		signals.players_all_dead.emit()


## Called to check if all players has been dead and their bodies have finished
## their performances. [br]
## If yes, then if the rest lives is greater than 0, one life will be taken down from all players;
## otherwise a signal [signal EventsManager.SignalsManager.game_over] will get emission [br]
## This is called when a player ends death process
static func player_all_death_process() -> void:
	var players := PlayersManager.get_all_available_players()
	if players.is_empty():
		if Data.player_lives > 0:
			Data.add_lives(-1)
			Scenes.reload_current_scene()
		else:
			signals.game_over.emit()


## Emits [signal EventsManager.SignalsManager.level_finished]
static func level_finish() -> void:
	signals.level_finished.emit()


## Emits [signal EventsManager.SignalsManager.level_done_finishing][br]
## [b]Caution:[/b] This method is called only when the level is finished, and better let a [Level]-like
## node call this function
static func level_done_finishing() -> void:
	signals.level_done_finishing.emit()
