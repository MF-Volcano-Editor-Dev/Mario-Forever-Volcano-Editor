extends Node

## A singleton used to manage scenes, such as the change to a scene and reloading of current scene.
##
##

## Modes for [method reload]
enum ReloadDataMode {
	NONE, ## Nothing will happen
	CLEAR, ## Some global data will be cleared
	OVERRIDE ## Some data will be overridden
}

var _cached_scene_path: String
var _cached_scene: PackedScene


func _init() -> void:
	process_mode = PROCESS_MODE_DISABLED


func cache_scene(scene: String) -> bool:
	if scene == _cached_scene_path:
		return true
	_cached_scene_path = scene
	ResourceLoader.load_threaded_request(_cached_scene_path, "", true)
	while !ResourceLoader.load_threaded_get_status(_cached_scene_path) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		await get_tree().process_frame
	_cached_scene = ResourceLoader.load_threaded_get(_cached_scene_path) as PackedScene
	return true


#region == Scenes managements ==
## Changes the current scene to scene from the [param file].[br]
## If [param override] is [code]true[/code], the characters' data will be overridden with the current one.
func jump_to_file(file: String, override: bool = true, reserve_character_data: bool = true) -> void:
	if override:
		CharactersManager2D.get_characters_data_list().register_all()
	if !reserve_character_data:
		CharactersManager2D.get_characters_data_list().unregister_all()
	if await cache_scene(file):
		get_tree().change_scene_to_file.call_deferred(_cached_scene)

## Changes the current scene to scene from the [param packed].
func jump_to_packed(scene: PackedScene, override: bool = true, reserve_character_data: bool = true) -> void:
	if override:
		CharactersManager2D.get_characters_data_list().register_all()
	if !reserve_character_data:
		CharactersManager2D.get_characters_data_list().unregister_all()
	if await cache_scene(scene.resource_path):
		get_tree().change_scene_to_packed.call_deferred(_cached_scene)

## Reloads the current scene with a [enum ReloadDataMode]
func reload(reloading_mode: ReloadDataMode = ReloadDataMode.CLEAR) -> void:
	match reloading_mode:
		ReloadDataMode.OVERRIDE:
			CharactersManager2D.get_characters_data_list().register_all()
		ReloadDataMode.CLEAR:
			CharactersManager2D.get_characters_data_list().unregister_all()
	get_tree().change_scene_to_packed(_cached_scene)
#endregion
