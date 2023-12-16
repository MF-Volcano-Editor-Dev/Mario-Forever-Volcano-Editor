class_name AddScores extends Component

const Scores := preload("res://objects/entities/#effects/scores_and_lives/scores.tscn")

@export_category("Add Scores")
@export_range(0, 1, 1, "or_greater", "hide_slider", "suffix:pts") var scores: int
@export_group("Sounds", "sound_")
@export var sound_scores: AudioStream

var _player_data := Data.get_player_data()

@onready var _root := get_root() as Node2D


func add_scores(show_text: bool = true) -> void:
	if disabled:
		return
	Sound.play_sound_2d(_root, sound_scores)
	_player_data.add_scores(scores)
	if show_text && _root:
		var eff := Scores.instantiate()
		eff.global_position = _root.global_position
		eff.set_shown_texts(scores)
		_root.add_sibling(eff)
