extends Node

@export_category("Hud Add Lives")
## Lives to be added for the player when the player reached to the maximum
@export_range(0, 20, 1, "suffix:lives") var coin_max_life_up: int = 1
## Sound of life up
@export var coin_to_life_sound: AudioStream = preload("res://assets/sounds/life_up.wav")


func _ready() -> void:
	Data.signals.player_coins_reached_max.connect(_on_coins_max)


func _on_coins_max() -> void:
	Data.add_lives(1)
	Sound.play_sound(self, coin_to_life_sound)
