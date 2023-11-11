class_name Level extends SceneGame

## Class used for stages
##
##

## Emitted when the finishing delay is up (the level is to be finished)
signal stage_to_be_finished

## Emitted when the level is finished
signal stage_finished

@export_group("Finish")
@export var finishing_music: AudioStream = preload("res://assets/musics/core/level_complete.ogg")
@export_range(0, 10, 0.001, "suffix:s") var finish_process_delay: float = 8
## Scene to go after the stage finished is emitted
@export var scene_after_finish: PackedScene


var _after_finish_wait_nodes: Array[Object]


func _enter_tree() -> void:
	EventsManager.signals.level_finished.connect(_on_level_finished)


#region Todo List after Finish
## Add an object to the finish process await list
func add_object_to_wait_finish(object: Object) -> void:
	if object in _after_finish_wait_nodes:
		return
	_after_finish_wait_nodes.append(object)


## Remove an object from the finish process await list
func remove_object_to_wait_finish(object: Object) -> void:
	if !object in _after_finish_wait_nodes:
		return
	_after_finish_wait_nodes.erase(object)
#endregion


func _on_level_finished() -> void:
	# Locks players status
	var players := PlayersManager.get_all_available_players()
	for i: EntityPlayer2D in players:
		i.state_machine.set_multiple_states([&"no_hurt", &"control_ignored", &"level_finished"])
	
	# Plays finishing music
	var music: AudioStreamPlayer = AudioStreamPlayer.new()
	music.stream = finishing_music
	music.bus = &"Music"
	add_child(music)
	music.play()
	music.finished.connect(music.queue_free)
	
	# Delay for seconds to make sure the music is done perfectly
	await get_tree().create_timer(finish_process_delay, false).timeout
	stage_to_be_finished.emit()
	
	# Await for the objecs that blocks the process in the list
	while !_after_finish_wait_nodes.is_empty():
		await get_tree().process_frame
	
	if scene_after_finish:
		# Remove player nodes from the tree first
		for j: EntityPlayer2D in players:
			j.state_machine.remove_multiple_states.call_deferred([&"no_hurt", &"control_ignored", &"level_finished"])
		PlayersManager.remove_all_players()
		# Change the scene
		get_tree().change_scene_to_packed.call_deferred(scene_after_finish)
	else:
		printerr("[Scene Changing Error] The scene to be warped to is invalid or not set yet!")
	
	stage_finished.emit()
