extends Area2D

@export_category("Stuck Head")
@export var stuck_head_to_powerup_id: StringName = &"small"

@onready var _powerup: MarioPowerup = get_parent()


func stop_head_overlapping_body() -> void:
	for i in 3:
		await get_tree().physics_frame
	if get_overlapping_bodies().is_empty():
		return
	# Manual hurt, but no invincible
	_powerup.get_character().hurt(2, true, false)
