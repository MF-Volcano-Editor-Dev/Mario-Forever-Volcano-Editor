extends Node

var _player_suits_list: Dictionary:
	get = get_player_suits


func _ready() -> void:
	for i: MarioSuit2D in get_children():
		var id: StringName = get_player_suit_id(i.character_id, i.suit_id)
		if !id in _player_suits_list:
			_player_suits_list.merge({id: load(i.scene_file_path)})
		i.free()


func get_player_suits() -> Dictionary:
	return _player_suits_list


func get_player_suit(id: StringName) -> MarioSuit2D:
	if !id in _player_suits_list:
		return null
	
	var pck: PackedScene = _player_suits_list[id] as PackedScene
	if !pck:
		return null
	
	return pck.instantiate()


func get_player_suit_id(character_id: StringName, suit_id: StringName) -> StringName:
	return character_id + &"/" + suit_id
