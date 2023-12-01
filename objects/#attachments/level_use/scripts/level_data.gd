class_name LevelEvents extends Component

@export_category("Level Data")
@export_group("Player Data")
@export_range(-10, 10, 1, "suffix:♥") var coin_to_lives: int = 1
@export_group("Sounds")
@export var sound_life: AudioStream = preload("res://assets/sounds/life_up.wav")


func _ready() -> void:
	Data.signals.player_coins_reached_max.connect(_on_player_coins_to_life)


func _on_player_coins_to_life() -> void:
	if disabled:
		return
	
	Data.add_lives(coin_to_lives)
	Sound.play_sound(self, sound_life)
