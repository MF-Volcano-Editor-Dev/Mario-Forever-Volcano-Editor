extends Component

const Scores := preload("res://objects/entities/#effects/scores_and_lives/scores.tscn")

@export_category("Scores Adder")
@export_range(-1, 1, 1, "or_less", "or_greater", "hide_slider", "suffix:scores") var scores: int
@export_group("Sounds", "sound_")
@export var sound_score: AudioStream


func add_score() -> void:
	Data.add_scores(scores)
	
	if root is Node2D:
		Sound.play_sound_2d(root, sound_score)
		var scr := Scores.instantiate()
		root.add_sibling.call_deferred(scr)
		scr.global_position = root.global_position
		scr.set_display(scores)
