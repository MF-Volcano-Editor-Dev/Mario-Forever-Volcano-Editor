class_name LevelCompletion extends Component

## A component used for level's completion
##
## When the method [method Events.level_finish] is called, the level will go into the procession
## that contains two sections:[br]
## > 1st section: In this section, a finishing music will be played and the system will wait for [member finish_process_delay] seconds.
## After the delay, if there is any object in the list mentioned in [method add_object_to_wait_finish], the system will not continue
## the execution of the second section until the list is empty [br]
## > 2nd section: Before the process of this section, if [method Events.level_stop_finishment] is called, then the e

@export_group("Level Completion")
## Delay to the next stage of level-completing process after the music was played
@export_range(0, 10, 0.001, "suffix:s") var finish_process_delay: float = 8
## Scene to go after the stage finished is emitted
@export var scene_after_finish: PackedScene
@export_group("Data")
@export var reserve_characters_data: bool = true
@export_group("Musics", "music_")
@export var music_completion: AudioStream = preload("res://assets/sounds/level_complete.ogg") ## Music to be played when the level is completed

#region Finishment related
var _stopped: bool
var _music_player: AudioStreamPlayer
var _delayer: SceneTreeTimer
#endregion
var _awaited_objects: Array[Object]


func _enter_tree() -> void:
	Events.signals.level_completed.connect(_on_level_completed)
	Events.signals.level_completion_stopped.connect(_on_level_stopped_completion)


#region Todo-list after the completion of the level
## Adds an object to the completion process await list [br]
## [b]Note:[/b] This will block the process of level completion to its second stage
func add_object_to_wait_finish(object: Object) -> void:
	if !is_instance_valid(object) || object in _awaited_objects:
		return
	_awaited_objects.append(object)

## Removes an object from the completion process await list [br]
## [b]Note:[/b] If there are no objects in the list mentioned in [method add_object_to_wait_finish]
## to block the process mentioned as well, the completion is able to go into the second
## section of process
func remove_object_to_wait_finish(object: Object) -> void:
	if !is_instance_valid(object) || !object in _awaited_objects:
		return
	_awaited_objects.erase(object)
#endregion


#region Level completion
## Play completion music
func play_completion_music() -> void:
	_music_player = Sound.play_sound(self, music_completion)

## Stop completion music
func stop_completion_music() -> void:
	if !is_instance_valid(_music_player):
		return
	_music_player.queue_free()

func _on_level_stopped_completion() -> void:
	if disabled:
		return
	_stopped = true
	stop_completion_music() # Stops the music
	if _delayer: # Quits the awaitness if the music is playing
		_delayer.timeout.emit()
	var players := CharactersManager2D.get_characters_getter().get_characters()
	for i: CharacterEntity2D in players:
		i.controllable = true
		i.get_flagger().set_flag(&"undamagible", false)

func _on_level_completed() -> void:
	if disabled:
		return
	
	# Locks players status
	var players := CharactersManager2D.get_characters_getter().get_characters()
	for i: CharacterEntity2D in players:
		i.controllable = false
		i.get_flagger().set_flag(&"undamagible", true)
	
	play_completion_music() # Plays finishing music
	
	# Delay for seconds to make sure the music is done thoroughly 
	_delayer = get_tree().create_timer(finish_process_delay, false)
	await _delayer.timeout
	_delayer = null
	if _stopped: # If the completion is stopped, then stops the execution
		return
	
	# Notices the completion has entered into the second stage
	# This is useful when a level timer is about to scoring
	Events.level_to_be_completed_state(0)
	
	# Await for the objects that blocks the process in the list
	# E.g. The level timer is scoring
	while !_awaited_objects.is_empty():
		if _stopped: # See the comment above
			return
		await get_tree().process_frame # A mini process frame loop
	
	# Changes the scene
	if scene_after_finish:
		Scenes.jump_to_packed(scene_after_finish) # Changes the scene
	else:
		printerr("[Scene Changing Error] The scene to be warped to is invalid or not set yet!") # Throws an error on failure
	
	Events.level_done_completion() # Notices the level's completion
#endregion
