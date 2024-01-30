extends Area2D

@onready var _powerup: MarioPowerup = get_parent()
@onready var _character: Character = _powerup.get_character()

var _stop_stuck_push: bool


func check_and_push() -> void:
	for i in 3:
		await get_tree().physics_frame
	if get_overlapping_bodies().is_empty():
		return
	
	_character.add_to_group(&"state_immovable")
	
	while !get_overlapping_bodies().is_empty():
		_character.global_position += Vector2.LEFT.rotated(_character.global_rotation) * _character.direction
		if !_stop_stuck_push:
			await get_tree().physics_frame
		else:
			break
	
	_character.remove_from_group(&"state_immovable")

func stop_pushing() -> void:
	_stop_stuck_push = true
	_character.remove_from_group(&"state_immovable")
	
	await get_tree().physics_frame
	
	_stop_stuck_push = false
