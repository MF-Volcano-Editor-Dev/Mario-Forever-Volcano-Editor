class_name AudioPlayer

## Static class that manages sound and music playing
##
##

## Playing mode of sounds and musics
enum PlayingMode {
	NODE, ## The sound can be played in a [Node] only
	SCENE,
	GLOBAL
}

static var musics: Array[AudioStreamPlayer]
