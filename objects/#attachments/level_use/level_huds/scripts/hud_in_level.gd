extends CanvasLayer

@export_category("Level HUD")
@export_group("Sounds", "sound_")
## Sound of game over
@export var sound_game_over: AudioStream = preload("res://assets/sounds/game_over.ogg")

@onready var lives: Label = $Frame/LivesX
@onready var scores: Label = $Frame/LivesX/Scores
@onready var coins: Label = $Frame/CoinsX/Coins
@onready var game_over: Label = $Frame/GameOver


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	Data.signals.player_data_changed.connect(
		func(data: StringName, value: int) -> void:
			match data:
				&"player_lives":
					var fpl := PlayersManager.get_first_player()
					var fpln := &"PLAYER" if !fpl else fpl.nickname
					lives.text = fpln + " × %s" % [str(value)]
				&"player_scores":
					scores.text = str(value)
				&"player_coins":
					coins.text = str(value)
	, CONNECT_DEFERRED)
	
	EventsManager.signals.game_over.connect(
		func() -> void:
			game_over.visible = true
			Sound.play_sound(self, sound_game_over)
	)
	
	Data.data_init_signal_emit()
