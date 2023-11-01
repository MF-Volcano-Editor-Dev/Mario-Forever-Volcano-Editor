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
	var res: Array[EntityPlayer2D] = []
	
	for i: EntityPlayer2D in _players:
		if !is_instance_valid(i):
			continue
		res.append(i)
	
	return res


static func get_first_player() -> EntityPlayer2D:
	return get_player(0)


static func get_last_player() -> EntityPlayer2D:
	return get_player(-1)


static func get_nearest_player(to: Vector2) -> EntityPlayer2D:
	var plys := get_all_available_players()
	if plys.is_empty():
		return null
	
	var pos: Array[float] = []
	
	for i: EntityPlayer2D in plys:
		pos.append((i.global_position - to).length_squared())
	var nr: float = pos.min()
	
	return plys[pos.find(nr)]
	
#endregion


#region Player Properties
static func get_average_global_position(camera: Camera2D = null) -> Vector2:
	var pls := get_all_available_players()
	if pls.is_empty():
		if is_instance_valid(camera):
			return camera.global_position
		else:
			return Vector2(NAN, NAN)
	
	var gpos := Vector2.ZERO
	for i: EntityPlayer2D in pls:
		gpos += i.global_position
	
	return gpos / float(pls.size())
#endregion


#region Players Addition and Removal
static func add_player(id: int, to: Node) -> void:
	var pl := get_player(id)
	
	if !is_instance_valid(to) || pl.is_inside_tree():
		return
	
	to.add_child.call_deferred(pl)


static func add_all_players(to: Node) -> void:
	if !is_instance_valid(to):
		return
	
	for i: EntityPlayer2D in get_all_available_players():
		if i.is_inside_tree():
			continue
		to.add_child.call_deferred(i)


static func remove_player(id: int) -> void:
	var pl := get_player(id)
	
	if !pl.is_inside_tree():
		return
	
	pl.get_parent().remove_child.call_deferred(pl)


static func remove_all_players() -> void:
	for i: EntityPlayer2D in get_all_available_players():
		if !i.is_inside_tree():
			continue
		i.get_parent().remove_child.call_deferred(i)
#endregion
