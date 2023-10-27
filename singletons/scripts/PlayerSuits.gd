extends Node

## A Singleton that manages the suits of each character
##
## [b]Note:[/b] the format of [member players_suit_list] should be:[br]
## &"character_id/suit_id" : preload(your_suit.tscn)

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
