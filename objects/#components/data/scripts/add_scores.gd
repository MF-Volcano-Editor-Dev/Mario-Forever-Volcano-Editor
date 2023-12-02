class_name AddScores extends Component

const Scores := preload("res://objects/entities/#effects/scores_and_lives/scores.tscn")

@export_category("Add Scores")
@export_range(0, 1, 1, "or_greater", "hide_slider", "suffix:pts") var scores: int
@export_group("Sounds", "sound_")
@export var sound_score: AudioStream


func add_scores(show_text: bool = true) -> void:
	if disabled:
		return
	
	Data.add_scores(scores)
	if show_text && _root is Node2D:
		var eff := Scores.instantiate()
		eff.global_position = _root.global_position
		eff.set_shown_texts(scores)
		_root.add_sibling(eff)
