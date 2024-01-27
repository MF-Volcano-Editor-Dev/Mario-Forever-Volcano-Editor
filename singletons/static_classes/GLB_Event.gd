class_name Events


class EventCharacter:
	class EventCharacterSignals:
		signal game_over ## Emitted when game over is triggered
	
	static var _signals: EventCharacterSignals = EventCharacterSignals.new()
	
	static func current_game_over(scene_tree: SceneTree) -> void:
		if Character.Getter.get_characters(scene_tree).is_empty():
			if Character.Data.lives > 0:
				Character.Data.lives -= 1
				scene_tree.reload_current_scene.call_deferred()
			else:
				_signals.game_over.emit()
	
	static func get_signals() -> EventCharacterSignals:
		return _signals
