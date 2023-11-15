extends Component

const Lives := preload("res://objects/entities/#effects/scores_and_lives/lives.tscn")

@export_category("Lives Adder")
@export_range(-1, 1, 1, "or_less", "or_greater", "hide_slider", "suffix:lives") var lives: int
@export_group("Sounds", "sound_")
@export var sound_life: AudioStream = preload("res://assets/sounds/life_up.wav")


func add_lives() -> void:
	Data.add_lives(lives)
	
	if root is Node2D:
		Sound.play_sound_2d(root, sound_life)
		var scr := Lives.instantiate()
		root.add_sibling.call_deferred(scr)
		scr.global_position = root.global_position
		scr.set_display(lives)
