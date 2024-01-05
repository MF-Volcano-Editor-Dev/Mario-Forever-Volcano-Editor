@icon("res://icons/character_entity_2d.svg")
class_name Mario extends Character


@export var current_powerup: StringName = &"small":
	set = set_powerup


func _ready() -> void:
	current_powerup = current_powerup # Triggers "set_powerup" to set initial powerup


func set_powerup(value: StringName) -> void:
	if !is_node_ready(): # To make sure the powerup is safely got
		return
	
	current_powerup = value
