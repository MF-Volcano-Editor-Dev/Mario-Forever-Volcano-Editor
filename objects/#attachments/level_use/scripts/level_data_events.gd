class_name LevelDataEvents extends Component

@export_category("Level Data Events")
@export_group("Settings", "enable")
@export var enable_coins_to_life: bool = true
@export var enable_game_over_handling: bool = true
@export_group("Player Data")
@export_range(-10, 10, 1, "suffix:♥") var coin_to_lives: int = 1
@export_group("Sounds")
@export var sound_life: AudioStream = preload("res://assets/sounds/life_up.wav")

var _player_data := Data.get_player_data()
var _game_events := Events.get_game_events()


func _ready() -> void:
	_player_data.player_coins_reached_max.connect(_on_player_coins_to_life)
	_game_events.game_over.connect(_on_game_over)


#region == Events ==
func _on_player_coins_to_life() -> void:
	if disabled || !enable_coins_to_life:
		return
	_player_data.add_lives(coin_to_lives)
	Sound.play_sound(self, sound_life)

func _on_game_over() -> void:
	if disabled || !enable_game_over_handling:
		return
	await get_tree().create_timer(8, false).timeout
	#TODO: This needs implementation
#endregion
