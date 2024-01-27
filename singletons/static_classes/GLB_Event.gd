class_name Events


class EventCharacter:
	static func current_game_over(scene_tree: SceneTree) -> void:
		if Character.Getter.get_characters(scene_tree).is_empty():
			scene_tree.reload_current_scene()
