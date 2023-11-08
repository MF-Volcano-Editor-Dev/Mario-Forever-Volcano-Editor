extends Node

@export_category("Death Area")
@export var death_detection_margin: float = 48
@export_group("Player Death")
@export var player_death_tags: Dictionary


func _process(_delta: float) -> void:
	var pls := PlayersManager.get_all_available_players()
	if pls.is_empty():
		return
	
	for i: EntityPlayer2D in pls:
		var rect := i.get_viewport_rect()
		var vpos := i.get_global_transform_with_canvas().get_origin()
		
		#if !rect.has_point(vpos):
			#continue
		
		var angl := i.get_gravity_vector().angle()
		var die := false
		
		if vpos.x > rect.size.x + death_detection_margin && angl >= -PI/4 && angl <= PI/4:
			die = true
		elif vpos.y > rect.size.y + death_detection_margin && angl >= PI/4 && angl <= 3*PI/4:
			die = true
		elif vpos.x < rect.position.x - death_detection_margin && angl >= 3*PI/4 || angl <= -3*PI/4:
			die = true
		elif vpos.y < rect.position.y - death_detection_margin && angl >= -3*PI/4 && angl <= -PI/4:
			die = true
		
		if die:
			i.die(player_death_tags)
