extends CanvasLayer

@onready var frame: Control = $Frame
@onready var lives: Label = $Frame/Lives
@onready var scores: Label = $Frame/Lives/Scores
@onready var coins: Label = $Frame/CoinX/Coins


func _ready() -> void:
	Character.Data.get_data_signal().data_updated.connect(
		func(type: Character.Data.DataSignal.Value, value: Variant) -> void:
			match type:
				Character.Data.DataSignal.Value.LIVES:
					const DEFAULT: StringName = &"PLAYER"
					lives.text = DEFAULT if Character.Getter.get_characters(get_tree()).is_empty() else Character.Getter.get_character(get_tree(), 0).nickname.to_upper() + &" × " + str(value)
				Character.Data.DataSignal.Value.SCORES:
					scores.text = str(value)
				Character.Data.DataSignal.Value.COINS:
					coins.text = str(value)
	, CONNECT_DEFERRED)
	Character.Data.init_data.call_deferred()
