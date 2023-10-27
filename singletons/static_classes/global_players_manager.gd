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
	_players.sort_custom(PlayersManager._sort_by_id)


static func unregister(id: int) -> void:
	if _players[id] != null:
		return
	
	_players[id] = null
#endregion


#region Player Getting
static func get_player(id: int) -> EntityPlayer2D:
	if id < 0 || id > _players.size() - 1:
		return null
	
	var player := _players[id]
	if !is_instance_valid(player):
		return null
	
	return player


static func get_all_available_players() -> Array[EntityPlayer2D]:
	var result: Array[EntityPlayer2D] = _players.duplicate()
	result.sort_custom(PlayersManager._sort_and_check)
	
	for i in result.size():
		var ins: EntityPlayer2D = result.pop_back()
		if is_instance_valid(ins):
			result.append(ins)
			break
	
	return result


static func get_first_player() -> EntityPlayer2D:
	return get_player(0)


static func get_last_player() -> EntityPlayer2D:
	return get_player(-1)
#endregion


#region Player Properties
static func get_average_global_position() -> Vector2:
	var players := get_all_available_players()
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


#region Private Methods
static func _sort_by_id(a: EntityPlayer2D, b: EntityPlayer2D) -> bool:
	if a.id == b.id:
		b.id += 1
	return a.id < b.id


static func _sort_and_check(a: EntityPlayer2D, b: EntityPlayer2D) -> bool:
	return is_instance_valid(a) && !is_instance_valid(b)
#endregion
