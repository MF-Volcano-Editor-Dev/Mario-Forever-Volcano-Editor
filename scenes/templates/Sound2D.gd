extends Sound2D

@export var sound: AudioStream


func _ready() -> void:
	await get_tree().create_timer(3).timeout
	play(sound)
