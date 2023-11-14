extends Component

const Scores := preload("res://objects/entities/#effects/scores_and_lives/scores.tscn")
const Lives := preload("res://objects/entities/#effects/scores_and_lives/lives.tscn")

@export_category("Scores/Lives Adder")
@export_group("Scores")
@export_range(-1, 1, 1, "or_less", "or_greater", "hide_slider", "suffix:scores") var scores: int
@export_group("Lives")
@export_range(-1, 1, 1, "or_less", "or_greater", "hide_slider", "suffix:lives") var lives: int
@export_group("Sounds", "sound_")
@export var sound_life: AudioStream = preload("res://assets/sounds/life_up.wav")


func add_score() -> void:
	Data.add_scores(scores)
	
	if root is Node2D:
		var scr := Scores.instantiate()
		root.add_sibling.call_deferred(scr)
		scr.global_position = root.global_position
		scr.set_display(scores)


func add_lives() -> void:
	Data.add_lives(lives)
	
	if root is Node2D:
		Sound.play_sound_2d(root, sound_life)
		var scr := Lives.instantiate()
		root.add_sibling.call_deferred(scr)
		scr.global_position = root.global_position
		scr.set_display(lives)
