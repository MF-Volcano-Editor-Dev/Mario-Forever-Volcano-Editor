extends Area2D

signal coin_got ## Emitted when the coin is got by a character.

@export_category("Coin")
@export_range(-9999, 9999) var amount: int = 1
@export_group("Sounds", "sound_")
@export var sound_coin: AudioStream = preload("res://assets/sounds/coin.wav")

@onready var _animation: AnimationPlayer = $AnimationPlayer # Used to play hit animation in which the coin will be automatically freed


func _ready() -> void:
	body_entered.connect(func(body: Node2D) -> void:
		if body is Character:
			Character.Data.coins += amount
			Sound.play_2d(sound_coin, self)
			coin_got.emit()
	)


func hit() -> void:
	_animation.play(&"hit")
	Sound.play_2d(sound_coin, self)
