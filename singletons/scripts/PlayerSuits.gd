extends Node

@export var player_suits_list: Dictionary= {
	&"mario/small": preload("res://objects/entities/players/mario/suits/mario_small.tscn"),
	&"mario/big": preload("res://objects/entities/players/mario/suits/mario_big.tscn"),
}


func get_player_suit(id: StringName) -> MarioSuit2D:
	if !id in player_suits_list:
		return null
	
	var pck: = player_suits_list[id] as PackedScene
	if !pck:
		return null
	
	return pck.instantiate()


func get_player_suit_id(character_id: StringName, suit_id: StringName) -> StringName:
	return character_id + &"/" + suit_id
