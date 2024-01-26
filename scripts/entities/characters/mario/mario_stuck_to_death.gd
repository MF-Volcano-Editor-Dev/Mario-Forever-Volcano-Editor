extends Area2D

@onready var _powerup: MarioPowerup = get_parent()


func _ready() -> void:
	body_entered.connect(_powerup.get_character().die.unbind(1))
