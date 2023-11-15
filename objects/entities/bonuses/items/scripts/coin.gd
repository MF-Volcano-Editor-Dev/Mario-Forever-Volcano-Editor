extends Area2D

## Emitted when a player touches the coin
signal player_touched


func _ready() -> void:
	area_entered.connect(
		func(area: Area2D) -> void:
			if area.get_parent() is EntityPlayer2D:
				player_touched.emit()
	, CONNECT_PERSIST)
