extends Node

## Static class that manages game events
##
##

## Access to the signals list of the class
var signals: SignalsManager = SignalsManager.new()


## Signals list of [Events]
class SignalsManager:
#region == Players related ==
	signal players_all_dead ## Emitted when all players are dead
	signal game_over ## Emitted when the game over is happening
#endregion
	
#region == Level related ==
	signal level_completed ## Emitted when the level is completed, but not done its completion
	signal level_completion_stopped ## Emitted when the level stops completion
	signal level_to_be_completed(state: int) ## Emitted when the level is about to completed, generally when the finishing music is end.
	signal level_done_completion ## Emitted when the level is done completion
#endregion


#region Player events
## Called to check if all players are dead, and emit [signal Events.SignalsManager.players_all_dead]
## if yes [br]
## This is called when a player starts death process
func player_all_death_detect() -> void:
	var players := CharactersManager2D.get_characters_getter().get_characters()
	if players.is_empty():
		signals.players_all_dead.emit()

## Called to check if all players has been dead and their bodies have finished
## their performances. [br]
## If yes, then if the rest lives is greater than 0, one life will be taken down from all players;
## otherwise a signal [signal Events.SignalsManager.game_over] will get emission [br]
## This is called when a player ends death process
func player_all_death_process(cached_characters: Array[CharacterEntity2D] = []) -> void:
	var players := CharactersManager2D.get_characters_getter().get_characters() if cached_characters.is_empty() else cached_characters
	if players.is_empty():
		if Data.player_lives > 0:
			Data.add_lives(-1)
			Scenes.reload(Scenes.ReloadDataMode.CLEAR) # Clear all data of characters
		else:
			signals.game_over.emit()
#endregion


#region Level events
## Emits [signal Events.SignalsManager.level_completed].
func level_complete() -> void:
	signals.level_completed.emit()

## Emits [signal Events.SignalsManager.level_completion_stopped].
func level_stop_completion() -> void:
	signals.level_completion_stopped.emit()

## Emits [signal Events.SignalsManager.level_done_completion].[br]
## [br]
## [b]Note:[/b] This method is called only when the level is finished, and better let a [Level]-like
## node call this function.
func level_done_completion() -> void:
	signals.level_done_completion.emit()

## Emits [signal Events.SignalsManager.level_to_be_completed] with a [param state].[br]
## [br]
## [b]Note:[/b] This method is called when there is something needs to interfere the completion, e.g. level timer's scoring
## that will block the completion.
func level_to_be_completed_state(state: int) -> void:
	signals.level_to_be_completed.emit(state)
#endregion
