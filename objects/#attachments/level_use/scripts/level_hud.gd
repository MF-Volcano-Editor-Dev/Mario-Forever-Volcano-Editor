@icon("res://icons/level_hud.svg")
class_name LevelHUD extends Classes.HiddenCanvasLayer

@export_category("Level HUD")
@export_group("Sounds", "sound_")
## Sound of game over
@export var sound_game_over: AudioStream = preload("res://assets/sounds/game_over.ogg")

var _player_data := Data.get_player_data()
var _game_events := Events.get_game_events()

#region == References ==
@onready var lives: Label = $Frame/LivesX
@onready var scores: Label = $Frame/LivesX/Scores
@onready var coins: Label = $Frame/CoinsX/Coins
@onready var game_over: Label = $Frame/GameOver
#endregion


func _ready() -> void:
	_player_data.player_data_changed.connect(_on_player_data_displayed)
	_game_events.game_over.connect(_on_game_over)


#region == Text displaying ==
func _on_player_data_displayed(data: StringName, value: int) -> void:
	match data:
		&"player_lives":
			var fpl := CharactersManager2D.get_characters_getter().get_character_with_id_min()
			var fpln := &"PLAYER" if !fpl else fpl.nickname
			lives.text = fpln + " × %s" % str(value)
		&"player_scores":
			scores.text = str(value)
		&"player_coins":
			coins.text = str(value)

func _on_game_over() -> void:
	game_over.visible = true
	Sound.play_sound(self, sound_game_over)
#endregion
