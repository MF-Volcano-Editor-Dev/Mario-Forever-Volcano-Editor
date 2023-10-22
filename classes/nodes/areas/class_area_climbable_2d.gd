class_name AreaClimbable2D extends Area2D

## Class of instances that allows [EntityPlayer2D] to climb on
##
## This class is designed for [EntityPlayer2D] and set the [member EntityPlayer2D.state_machine]
## of the player, especially for [Mario2D]

var _players: Array[EntityPlayer2D]


func _ready() -> void:
	body_entered.connect(
		func(body: Node2D) -> void:
			if body in _players:
				return
			_players.append(body as EntityPlayer2D)
	)
	
	body_exited.connect(
		func(body: Node2D) -> void:
			if !body in _players:
				return
			_players.erase(body)
			body.state_machine.remove_state(&"climbing")
	)


func _process(_delta: float) -> void:
	for i: EntityPlayer2D in _players:
		if is_instance_valid(i) && i.get_suit().behavior.get_up_down() < 0:
			i.state_machine.set_state(&"climbing")
