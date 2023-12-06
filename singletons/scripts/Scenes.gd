extends Node

## A singleton used to manage scenes, such as the change to a scene and reloading of current scene.
##
##

## Modes for [method reload]
enum ReloadDataMode {
	NONE, ## Nothing will happen
	CLEAR, ## The character data will be cleared
	OVERRIDE ## The character data will be overridden
}


func _init() -> void:
	process_mode = PROCESS_MODE_DISABLED


#region == Scenes managements ==
## Changes the current scene to scene from the [param file].[br]
## If [param override] is [code]true[/code], the characters' data will be overridden with the current one.
func jump_to_file(file: String, override: bool = true, reserve_character_data: bool = true) -> void:
	if override:
		CharactersManager2D.get_characters_data_list().register_all()
	if !reserve_character_data:
		CharactersManager2D.get_characters_data_list().unregister_all()
	get_tree().change_scene_to_file.call_deferred(file)

## Changes the current scene to scene from the [param packed].
func jump_to_packed(scene: PackedScene, override: bool = true, reserve_character_data: bool = true) -> void:
	if override:
		CharactersManager2D.get_characters_data_list().register_all()
	if !reserve_character_data:
		CharactersManager2D.get_characters_data_list().unregister_all()
	get_tree().change_scene_to_packed.call_deferred(scene)

## Reloads the current scene with a [enum ReloadDataMode]
func reload(reloading_mode: ReloadDataMode = ReloadDataMode.CLEAR) -> void:
	match reloading_mode:
		ReloadDataMode.OVERRIDE:
			CharactersManager2D.get_characters_data_list().register_all()
		ReloadDataMode.CLEAR:
			CharactersManager2D.get_characters_data_list().unregister_all()
	get_tree().reload_current_scene.call_deferred()
#endregion
