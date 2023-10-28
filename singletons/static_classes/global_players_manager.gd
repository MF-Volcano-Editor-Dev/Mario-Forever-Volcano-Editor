class_name PlayersManager

## Static class to manage players
##
##

static var _players: Array[EntityPlayer2D]


#region Players Registerations
static func register(player: EntityPlayer2D) -> void:
	if !is_instance_valid(player):
		return
	
	if player in _players:
		return
	
	_players.append(player)


static func unregister(id: int) -> void:
	if _players[id] != null:
		return
	
	_players[id] = null
#endregion


#region Player Getting
static func get_player(id: int) -> EntityPlayer2D:
	if id < 0 || id > _players.size() - 1:
		return null
	
	for i: EntityPlayer2D in _players:
		if is_instance_valid(i) && i.id == id:
			return i
	
	return null


static func get_all_available_players() -> Array[EntityPlayer2D]:
	var result: Array[EntityPlayer2D] = []
	
	for i: EntityPlayer2D in _players:
		if !is_instance_valid(i):
			continue
		result.append(i)
	
	return result


static func get_first_player() -> EntityPlayer2D:
	return get_player(0)


static func get_last_player() -> EntityPlayer2D:
	return get_player(-1)
#endregion


#region Player Properties
static func get_average_global_position(camera: Camera2D = null) -> Vector2:
	var players := get_all_available_players()
	if players.is_empty():
		if is_instance_valid(camera):
			return camera.global_position
		else:
			return Vector2(NAN, NAN)
	
	var gpos := Vector2.ZERO
	for i: EntityPlayer2D in players:
		gpos += i.global_position
	
	return gpos / float(players.size())
#endregion


#region Players Addition and Removal
static func add_player(id: int, to: Node) -> void:
	var player := get_player(id)
	
	if !is_instance_valid(to) || player.is_inside_tree():
		return
	
	to.add_child.call_deferred(player)


static func add_all_players(to: Node) -> void:
	if !is_instance_valid(to):
		return
	
	for i: EntityPlayer2D in get_all_available_players():
		if i.is_inside_tree():
			continue
		to.add_child.call_deferred(i)


static func remove_player(id: int) -> void:
	var player := get_player(id)
	
	if !player.is_inside_tree():
		return
	
	player.get_parent().remove_child.call_deferred(player)


static func remove_all_players() -> void:
	for i: EntityPlayer2D in get_all_available_players():
		if !i.is_inside_tree():
			continue
		i.get_parent().remove_child.call_deferred(i)
#endregion
