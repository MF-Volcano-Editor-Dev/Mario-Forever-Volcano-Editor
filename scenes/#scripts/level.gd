class_name Level extends SceneGame

## Class used for stages
##
## When the method [method EventsManager.level_finish] is called, the level will go into the procession
## that contains two sections:[br]
## > 1st section: In this section, a finishing music will be played and the system will wait for [member finish_process_delay] seconds.
## After the delay, if there is any object in the list mentioned in [method add_object_to_wait_finish], the system will not continue
## the execution of the second section until the list is empty [br]
## > 2nd section: Before the process of this section, if [method EventsManager.level_stop_finishment] is called, then the e

signal stage_to_be_finished ## Emitted when the finishing delay is up (the level is to be finished)
signal stage_finished ## Emitted when the level is finished

@export_group("Finish")
## Music to be played when the level is completed
@export var finishing_music: AudioStream = preload("res://assets/sounds/level_complete.ogg")
## Delay to the next stage of level-completing process after the music was played
@export_range(0, 10, 0.001, "suffix:s") var finish_process_delay: float = 8
## Scene to go after the stage finished is emitted
@export var scene_after_finish: PackedScene

#region Finishment related
var _finishment_stopped: bool
var _finish_music_player: AudioStreamPlayer
#endregion
var _finishment_awaited_objects: Array[Object]


func _enter_tree() -> void:
	EventsManager.signals.level_stopped_finishement.connect(_on_level_stopped_finishment)
	EventsManager.signals.level_finished.connect(_on_level_finished)


#region Todo-list after the completion of the level
## Adds an object to the finish process await list [br]
## [b]Note:[/b] This will block the process of level complemention to its second stage
func add_object_to_wait_finish(object: Object) -> void:
	if !is_instance_valid(object) || object in _finishment_awaited_objects:
		return
	_finishment_awaited_objects.append(object)

## Removes an object from the finish process await list [br]
## [b]Note:[/b] If there are no objects in the list mentioned in [method add_object_to_wait_finish]
## to block the process mentioned as well, the completion is able to go into the second
## section of process
func remove_object_to_wait_finish(object: Object) -> void:
	if !is_instance_valid(object) || !object in _finishment_awaited_objects:
		return
	_finishment_awaited_objects.erase(object)
#endregion


#region Level completion
## Play finishing music
func play_finishing_music() -> void:
	_finish_music_player = Sound.play_sound(self, finishing_music)

## Stop finishing music
func stop_finishing_music() -> void:
	if !is_instance_valid(_finish_music_player):
		return
	_finish_music_player.queue_free()

func _on_level_stopped_finishment() -> void:
	_finishment_stopped = true

func _on_level_finished() -> void:
	# Locks players status
	var players := await CharactersManager2D.get_characters_getter().get_characters(get_tree())
	for i: CharacterEntity2D in players:
		i.controllable = false
		ObjectState.set_state(i, CharacterEntity2D.STATE_UNDAMAGIBLE, true)
	
	# Plays finishing music
	play_finishing_music()
	
	# Delay for seconds to make sure the music is done perfectly
	await get_tree().create_timer(finish_process_delay, false).timeout
	stage_to_be_finished.emit()
	
	# Await for the objecs that blocks the process in the list
	while !_finishment_awaited_objects.is_empty():
		await get_tree().process_frame
	
	if _finishment_stopped:
		_finishment_stopped = false
		return
	
	# Try changing the scene
	if scene_after_finish:
		# Changes the scene
		get_tree().change_scene_to_packed(scene_after_finish)
	else:
		printerr("[Scene Changing Error] The scene to be warped to is invalid or not set yet!")
	
	stage_finished.emit()
#endregion
