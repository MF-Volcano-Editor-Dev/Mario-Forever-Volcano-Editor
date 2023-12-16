class_name AddLives extends Component

const Lives := preload("res://objects/entities/#effects/scores_and_lives/lives.tscn")

@export_category("Add Lives")
@export_range(0, 1, 1, "or_greater", "hide_slider", "suffix:lves") var lives: int = 1
@export_group("Sounds", "sound_")
@export var sound_lives: AudioStream = preload("res://assets/sounds/life_up.wav")

var _player_data := Data.get_player_data()

@onready var _root := get_root() as Node2D


func add_lives(show_text: bool = true) -> void:
	if disabled:
		return
	Sound.play_sound_2d(_root, sound_lives)
	_player_data.add_lives(lives)
	if show_text && _root:
		var eff := Lives.instantiate()
		eff.global_position = _root.global_position
		eff.set_shown_texts(lives)
		_root.add_sibling(eff)
