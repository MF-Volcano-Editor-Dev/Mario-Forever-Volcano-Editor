class_name Data

## Static class that manages game data
##
##

static var signals: SignalsManager = SignalsManager.new()


class SignalsManager:
	## Emitted when the [member player_coins] is euqal to [member player_max_coins]
	signal player_coins_reached_max
	
	## Emitted when the property in this class is changed
	signal player_data_changed(property: StringName, value: int)


#region Data of Player
## Lives of players
static var player_lives: int = ProjectSettings.get_setting("game/data/player/default_lives", 0):
	set(value):
		player_lives = clampi(value, 0, 99)
		signals.player_data_changed.emit(&"player_lives", player_lives)

## Maximum of [member player_coins]
static var player_max_coins: int = 100:
	set(value):
		player_max_coins = clampi(value, 0, 100_000)

## Coins of players [br]
## If reaching [member player_max_coins], the signal [member player_coins_reached_max] will be emitted
static var player_coins: int:
	set(value):
		player_total_coins += value - player_coins
		player_coins = value
		while value > player_max_coins:
			value -= player_max_coins
			signals.player_coins_reached_max.emit()
		signals.player_data_changed.emit(&"player_coins", player_coins)

## Total accumulation of [member player_coins] [br]
## Useful when you are developing a shopping system
static var player_total_coins: int:
	set(value):
		player_total_coins = clampi(value, 0, 100_000_000_000)

## Scores of players
static var player_scores: int:
	set(value):
		player_scores = clampi(value, 0, 100_000_000_000)
		signals.player_data_changed.emit(&"player_scores", player_scores)
#endregion


#region Functions of Players' Data
static func data_init_signal_emit() -> void:
	player_lives = player_lives
	player_coins = player_coins
	player_scores = player_scores

## Fast access to adding [member player_lives] [br]
## [b]Note:[/b] If [param amount] is negative, this call will lead to subtraction of the property
static func add_lives(amount: int) -> void:
	player_lives += amount


## Fast access to adding [member player_scores] [br]
## [b]Note:[/b] If [param amount] is negative, this call will lead to subtraction of the property
static func add_scores(amount: int) -> void:
	player_scores += amount


## Fast access to adding [member player_coins] [br]
## [b]Note:[/b] If [param amount] is negative, this call will lead to subtraction of the property
static func add_coins(amount: int) -> void:
	player_coins += amount
#endregion
