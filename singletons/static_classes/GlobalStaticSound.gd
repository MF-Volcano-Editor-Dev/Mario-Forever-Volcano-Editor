class_name Sound

## Static class that manages playing sound.
##
##

## List of modes that used in play_sound_*() methods
enum SoundMode {
	SCENIAL, # Sound will be played only in the current scene, and will be stopped if out of the scene
	GLOBAL # Sound will be played in the whole game, ignoring the change to another scene
}


## Plays an sound on n [param node] with [param stream] to be played.[br]
## For 2D sounds, see [method play_sound_2d].[br]
## For 3D sounds, see [method play_sound_3d].[br]
static func play_sound(node: Node, stream: AudioStream, mode: SoundMode = SoundMode.SCENIAL, bus: StringName = &"Sound") -> AudioStreamPlayer:
	if !node || !stream: 
		return
	
	var au := AudioStreamPlayer.new()
	au.stream = stream
	au.bus = bus
	
	var current_scene := node.get_tree().current_scene
	match mode:
		SoundMode.SCENIAL:
			current_scene.add_child.call_deferred(au)
		SoundMode.GLOBAL:
			current_scene.add_sibling.call_deferred(au)
	
	au.finished.connect(au.queue_free)
	au.play.call_deferred()
	
	return au


## Plays an sound on n [param node_2d] with [param stream] to be played in a 2D space.[br]
## For 1D sounds, see [method play_sound].[br]
## For 3D sounds, see [method play_sound_3d].[br]
static func play_sound_2d(node_2d: Node2D, stream: AudioStream, mode: SoundMode = SoundMode.SCENIAL, bus: StringName = &"Sound") -> AudioStreamPlayer2D:
	if !node_2d || !stream: 
		return
	
	var au := AudioStreamPlayer2D.new()
	au.global_transform = node_2d.global_transform
	au.stream = stream
	au.bus = bus
	
	var current_scene := node_2d.get_tree().current_scene
	match mode:
		SoundMode.SCENIAL:
			current_scene.add_child.call_deferred(au)
		SoundMode.GLOBAL:
			current_scene.add_sibling.call_deferred(au)
	
	au.finished.connect(au.queue_free)
	au.play.call_deferred()
	
	return au


## Plays an sound on n [param node_2d] with [param stream] to be played in a 3D space.[br]
## For 1D sounds, see [method play_sound].[br]
## For 2D sounds, see [method play_sound_2d].[br]
static func play_sound_3d(node_3d: Node3D, stream: AudioStream, mode: SoundMode = SoundMode.SCENIAL, bus: StringName = &"Sound") -> AudioStreamPlayer3D:
	if !node_3d || !stream: 
		return
	
	var au := AudioStreamPlayer3D.new()
	au.global_transform = node_3d.global_transform
	au.stream = stream
	au.bus = bus
	
	var current_scene := node_3d.get_tree().current_scene
	match mode:
		SoundMode.SCENIAL:
			current_scene.add_child.call_deferred(au)
		SoundMode.GLOBAL:
			current_scene.add_sibling.call_deferred(au)
	
	au.finished.connect(au.queue_free)
	au.play.call_deferred()
	
	return au
