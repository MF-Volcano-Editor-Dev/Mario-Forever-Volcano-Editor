extends Node2D

var _player_suits_list: Dictionary:
	get = get_player_suits


func _ready() -> void:
	for i: MarioSuit2D in get_children():
		var id: StringName = i.character_id + &"/" + i.suit_id
		if !id in _player_suits_list:
			_player_suits_list.merge({id: load(i.scene_file_path)})
		queue_free()


func get_player_suits() -> Dictionary:
	return _player_suits_list


func get_player_suit(id: StringName) -> MarioSuit2D:
	if !id in _player_suits_list:
		printerr("No such id %s registered!" % [id])
		return null
	return (_player_suits_list[id] as PackedScene).instantiate()
