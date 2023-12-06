extends Node

## A singleton that manages game data
##
## All players' data are managed by this singleton, such as the lives, scores, coins, etc.
## You can connect signals from [member signals] object to listen to the changes of relative
## data instead of getting them continuously in a process loop to increase performance. While
## the data is got by the listening to the signals' emissions, you need to call
## [method data_init_signal_emit] to make [member signals] emit signals for each element of the data
## in order to make sure the listeners can get the correct information and works better on initialization.

var _player_data: PlayerData = PlayerData.new() ## Access to the signals list of the class


func _init() -> void:
	process_mode = PROCESS_MODE_DISABLED


#region == Player data ==
## Signals list of the singleton Data
class PlayerData:
	signal player_coins_reached_max ## Emitted when the [member player_coins] is euqal to [member player_max_coins]
	signal player_data_changed(property: StringName, value: int) ## Emitted when the property in this class is changed, connected with deferred flag!
	
	#region Data of characters
	## Lives of players
	var player_lives: int = ProjectSettings.get_setting("game/data/player/default_lives", 0):
		set(value):
			player_lives = clampi(value, 0, 99)
			player_data_changed.emit(&"player_lives", player_lives)
	## Maximum of [member player_coins]
	var player_max_coins: int = 100:
		set(value):
			player_max_coins = clampi(value, 0, 100_000)
	## Coins of players [br]
	## If reaching [member player_max_coins], the signal [member player_coins_reached_max] will be emitted.
	var player_coins: int:
		set(value):
			player_total_coins += value - player_coins
			player_coins = value
			while player_coins >= player_max_coins:
				player_coins -= player_max_coins
				player_coins_reached_max.emit()
			player_data_changed.emit(&"player_coins", player_coins)
	## Total accumulation of [member player_coins].
	## Useful when you are developing a shopping system
	var player_total_coins: int:
		set(value):
			player_total_coins = clampi(value, 0, 100_000_000_000)
	## Scores of players
	var player_scores: int:
		set(value):
			player_scores = clampi(value, 0, 100_000_000_000)
			player_data_changed.emit(&"player_scores", player_scores)
	#endregion
	
	
	#region == Functions of management of players' data ==
	## Called when the data should be initialized
	func data_init_signal_emit() -> void:
		player_lives = player_lives
		player_coins = player_coins
		player_scores = player_scores
	
	## Fast access to adding [member player_lives][br]
	## If [param amount] is negative, this call will lead to subtraction of the property
	func add_lives(amount: int) -> void:
		player_lives += amount
	
	## Fast access to adding [member player_scores][br]
	## If [param amount] is negative, this call will lead to subtraction of the property
	func add_scores(amount: int) -> void:
		player_scores += amount
	
	## Fast access to adding [member player_coins][br]
	## If [param amount] is negative, this call will lead to subtraction of the property
	func add_coins(amount: int) -> void:
		player_coins += amount
	#endregion
#endregion


#region == Getters ==
func get_player_data() -> PlayerData:
	return _player_data
#endregion
