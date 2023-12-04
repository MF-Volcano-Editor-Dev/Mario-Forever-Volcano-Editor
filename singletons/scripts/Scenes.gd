extends Node

enum ReloadDataMode {
	NONE,
	CLEAR,
	OVERRIDE
}


func jump_to_file(file: String, override: bool = true) -> void:
	if override:
		CharactersManager2D.get_characters_data_list().register_all()
	get_tree().change_scene_to_file(file)

func jump_to_packed(scene: PackedScene, override: bool = true) -> void:
	if override:
		CharactersManager2D.get_characters_data_list().register_all()
	get_tree().change_scene_to_packed(scene)

func reload(reloading_mode: ReloadDataMode = ReloadDataMode.CLEAR) -> void:
	match reloading_mode:
		ReloadDataMode.OVERRIDE:
			CharactersManager2D.get_characters_data_list().register_all()
		ReloadDataMode.CLEAR:
			CharactersManager2D.get_characters_data_list().unregister_all()
	get_tree().reload_current_scene()
