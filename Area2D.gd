extends Area2D

var _player: EntityPlayer2D


func _ready() -> void:
	body_entered.connect(
		func(body: Node2D) -> void:
			_player = body as EntityPlayer2D
	)
	
	body_exited.connect(
		func(body: Node2D) -> void:
			if body == _player:
				_player = null
				body.state_machine.remove_state(&"climbing")
	)


func _process(_delta: float) -> void:
	if _player && _player.get_suit().behavior.get_up_down() < 0:
		_player.state_machine.set_state(&"climbing")
