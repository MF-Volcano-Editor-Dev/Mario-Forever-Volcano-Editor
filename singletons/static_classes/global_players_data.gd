class_name PlayersData

## Static class used to store global player datas
##
##

static var players: Array[EntityPlayer2D]


##regionbegin PlayersManagements
func register(player: EntityPlayer2D) -> void:
	if !is_instance_valid(player):
		return
	
	_auto_extend(player.id)
	
	if player in players:
		return
	
	players.append(player)
##endregion


func _auto_extend(id: int) -> void:
	if id > players.size() - 1:
		players.resize(id + 1)
