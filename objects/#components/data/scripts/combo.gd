class_name Combo extends Component

@export_category("Combo")
@export var combo_scores: Array[int] = [100, 200, 500, 1000, 2000, 5000]
@export_group("Sounds", "sound_")
@export var sound_combo: AudioStream = preload("res://assets/sounds/kick.wav")
@export var sound_scores: AudioStream
@export var sound_lives: AudioStream = preload("res://assets/sounds/life_up.wav")

var _count: int

@onready var _root := get_root() as Node2D
@onready var add_scores: AddScores = $AddScores
@onready var add_lives: AddLives = $AddLives


func _ready() -> void:
	add_scores._root = _root
	add_lives._root = _root

#region == Counting combo ==
func combo() -> void:
	if disabled:
		return
	
	var snd := Sound.play_sound_2d(_root, sound_combo)
	snd.pitch_scale = 1 + 0.14 * _count
	
	var maximum := combo_scores.size()
	if _count < maximum:
		add_scores.scores = combo_scores[_count]
		add_scores.add_scores()
	_count += 1
	if add_lives.lives > 0:
		if _count > maximum: # Adds lives if lives > 0
			add_lives.add_lives()
			reset()
	elif _count >= maximum:
		reset()

func reset() -> void:
	_count = 0
#endregion
