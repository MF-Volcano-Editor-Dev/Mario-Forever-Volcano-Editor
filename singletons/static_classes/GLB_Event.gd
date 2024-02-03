class_name Events

## Static class that manages game events.
##
## Game events in this static class are stored in separate subclasses:[br]
## * [Events.EventCharacter]: Used to store events related to characters, like game over.[br]
## [br]
## To trigger a game event, you can call the relative method to activate it. 
## Sometimes the function requires a [SceneTree] to be passed in because this is not a singleton extending [Node].[br]
## Before the static signals being implemented, each subclass has, generally, a unique subclass as its signal controller to store the signals.
## To listen to a game event, call [code]get_signals()[/code] in respective subclass.
## [codeblock]
## # Here we take EventCharacter's game_over as an example:
## EventCharacter.get_signals().game_over.connect(...)
## [/codeblock]


## Subclass of [Events], which is used to manage the events related to characters, including game over and completion of a level.
##
## To listen to the signals, please call [method get_signals] and see [Events.EventCharacter.EventCharacterSignals]
class EventCharacter:
	## Subclass of [Events.EventCharacter] that helps store signals.
	class Signals:
		signal character_dead(id: int) ## Emitted when a characters dies.
		signal all_characters_dead ## Emitted when all characters are dead.
		signal game_over ## Emitted when event "game over" is triggered.
	
	static var _signals: Signals = Signals.new()
	
	## Notify that a character dies.[br]
	## This call will trigger the emission of [Events.EventCharacter.EventCharacterSignals.character_dead], and even [Events.EventCharacter.EventCharacterSignals.all_characters_dead] when all players are dead.
	static func notify_character_death(scene_tree: SceneTree, id: int) -> void:
		_signals.character_dead.emit(id)
		if Character.Getter.get_characters(scene_tree).is_empty():
			_signals.all_characters_dead.emit()
			EventTimeDown.get_signals().time_down_paused.emit()
	
	## Triggers the event "current game over".[br]
	## [br]
	## [b]Note:[/b] "Current game over" means that all characters are dead in the level, which requires the level to restart and cost 1 life, or to show "GAME OVER" if the lives is 0.
	static func current_game_over(scene_tree: SceneTree) -> void:
		if !Character.Getter.get_characters(scene_tree).is_empty():
			return
		
		if Character.Data.lives > 0:
			Character.Data.lives -= 1
			scene_tree.reload_current_scene.call_deferred()
		else:
			_signals.game_over.emit()
	
	## Returns [Events.EventCharacter.Signals]
	static func get_signals() -> Signals:
		return _signals

## Subclass of [Events], which is used to manage the events related to timer down.
##
## To listen to the signals, please call [method get_signals] and see [Events.EventTimeDown.Signals]
class EventTimeDown:
	## Subclass of [Events.EventTimeDown] that helps store signals.
	class Signals:
		signal time_down_paused ## Emitted when making the timer pause.
		signal time_down_resume ## Emitted when making the timer resume.
	
	static var _signals: Signals = Signals.new()
	
	## Returns [Events.EventTimeDown.Signals]
	static func get_signals() -> Signals:
		return _signals


class EventGame:
	## Subclass of [Events.EventTimeDown] that helps store signals.
	class Signals:
		signal completed_level ## Emitted when a level is completed.
	
	static var _signals: Signals = Signals.new()
	
	## Returns [Events.EventGame.Signals]
	static func get_signals() -> Signals:
		return _signals
