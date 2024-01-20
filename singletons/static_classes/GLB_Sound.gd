class_name Sound

## Static class that manages the playing of sounds
##
##

## The mode of playing a sound.[br]
## [br]
## [b]Note:[/b] Since the sounds are played via [AudioStreamPlayer]*, which is a kind of [Node],
## the position of the sound player decides the behavior of it. 
enum Mode {
	AS_CHILD, ## The sound player will be added as the child node of one that gets the sound wanted to play (The [b]owner[/b] of the sound player).[br][b]Note:[/b] If the owner gets removed or deleted, the sound player will be done so as well and the sound will break playing.
	SCENIAL, ## The sound player will be added as the child node of the [u]current scene[/u] of the scene tree. This won't break the playing of the sound even if the owner of the sound player gets removed or deleted.
	GLOBAL ## The sound player will be added as the child node of the [u]root[/u] of the scene tree. This won't break the playing of the sound even if the owner of the sound player gets removed or deleted, or the current scene gets changed.
}

## Plays a sound in the 2D space.
static func play_2d(stream: AudioStream, owner: Node2D, area_mask: int = int(ProjectSettings.get_setting("game/data/sound/default_area_mask", 1)), mode: Mode = Mode.SCENIAL) -> AudioStreamPlayer2D:
	if !stream || !is_instance_valid(owner) || !owner.is_inside_tree():
		return null
	
	var snd: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	snd.area_mask = area_mask
	snd.stream = stream
	
	(func() -> void: # Called deferredly to make sure the sound player will be safely added
		match mode:
			Mode.AS_CHILD:
				owner.add_child(snd)
			Mode.SCENIAL:
				owner.get_tree().current_scene.add_child(snd)
			Mode.GLOBAL:
				owner.get_tree().root.add_child(snd)
		snd.global_transform = owner.global_transform
		snd.finished.connect(snd.queue_free)
		snd.play()
	).call_deferred()
	
	return snd
