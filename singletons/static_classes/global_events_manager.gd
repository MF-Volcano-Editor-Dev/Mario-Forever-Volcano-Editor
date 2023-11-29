class_name EventsManager

## Static class that manages game events
##
##

## Access to the signals list of the class
static var signals: SignalsManager = SignalsManager.new()


## Signals list of [EventsManager]
class SignalsManager:
	signal players_all_dead ## Emitted when all players are dead
	signal game_over ## Emitted when the game over is happening
	signal level_finished ## Emitted when the level is finished
	signal level_stopped_finishement ## Emitted when the level stops finishment
	signal level_done_finishing ## Emitted when the level is done finishing


#region Player events
## Called to check if all players are dead, and emit [signal EventsManager.SignalsManager.players_all_dead]
## if yes [br]
## This is called when a player starts death process
static func player_all_death_detect(tree) -> void:
	var players := await CharactersManager2D.get_characters_getter().get_characters(tree)
	if players.is_empty():
		signals.players_all_dead.emit()

## Called to check if all players has been dead and their bodies have finished
## their performances. [br]
## If yes, then if the rest lives is greater than 0, one life will be taken down from all players;
## otherwise a signal [signal EventsManager.SignalsManager.game_over] will get emission [br]
## This is called when a player ends death process
static func player_all_death_process(tree: SceneTree) -> void:
	var players := await CharactersManager2D.get_characters_getter().get_characters(tree)
	if players.is_empty():
		if Data.player_lives > 0:
			Data.add_lives(-1)
			tree.reload_current_scene()
		else:
			signals.game_over.emit()
#endregion


#region Level events
## Emits [signal EventsManager.SignalsManager.level_finished]
static func level_finish() -> void:
	signals.level_finished.emit()

## Emits [signal EventsManager.SignalsManager.level_finishment_stopped]
static func level_stop_finishment() -> void:
	signals.level_stopped_finishement.emit()

## Emits [signal EventsManager.SignalsManager.level_done_finishing][br]
## [b]Caution:[/b] This method is called only when the level is finished, and better let a [Level]-like
## node call this function
static func level_done_finishing() -> void:
	signals.level_done_finishing.emit()
#endregion
