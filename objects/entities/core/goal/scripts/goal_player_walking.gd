extends Node

@export_category("Goal End Line")
@export_enum("Left: -1", "Right: 1") var walking_direction: int = 1
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var walking_speed: float = 100

var _players: Array[EntityPlayer2D]


func _process(delta: float) -> void:
	for i: EntityPlayer2D in _players:
		i.speed = move_toward(i.speed, walking_direction * walking_speed, 400 * delta)
		
		if i.is_on_wall():
			_players.erase(i)


func add_player(player: EntityPlayer2D) -> void:
	if player in _players:
		return
	_players.append(player)
