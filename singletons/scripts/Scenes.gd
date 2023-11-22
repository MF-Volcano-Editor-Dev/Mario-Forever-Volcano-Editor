extends Node


func jump_to_scene_packed(scene: PackedScene, clear_all_player_state: bool = true) -> void:
	if clear_all_player_state:
		_clear_all_player_states()
	get_tree().change_scene_to_packed(scene)


func jump_to_scene_path(scene_path: String, clear_all_player_state: bool = true) -> void:
	if clear_all_player_state:
		_clear_all_player_states()
	get_tree().change_scene_to_file(scene_path)


func reload_current_scene(clear_all_player_state: bool = true) -> void:
	if clear_all_player_state:
		_clear_all_player_states()
	get_tree().reload_current_scene()


func _clear_all_player_states() -> void:
	for i: EntityPlayer2D in PlayersManager.get_all_available_players():
		i.state_machine.clear_all_states()
	PlayersManager.remove_all_players()
