extends Component

@export_category("Coins Adder")
@export_range(-1, 1, 1, "or_less", "or_greater", "hide_slider", "suffix:$") var coins: int = 1
@export_group("Sounds", "sound_")
@export var sound_coin: AudioStream = preload("res://assets/sounds/coin.wav")


func add_coins() -> void:
	Data.add_coins(coins)
	
	if root is Node2D:
		Sound.play_sound_2d(root, sound_coin)
