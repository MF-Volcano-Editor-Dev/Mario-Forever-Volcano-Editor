extends Node

@export_category("Character Underwater")
@export var head: Area2D
@export var body: Area2D

@onready var _powerup: MarioPowerup = get_parent()
@onready var _character: Mario = _powerup.get_parent()


func _ready() -> void:
	if head:
		head.area_entered.connect(_on_head_detected_entered)
		head.area_exited.connect(_on_head_detected_exited)
	if body:
		body.area_entered.connect(_on_body_detected_area)
		body.area_exited.connect(_on_body_detected_exited)


func _on_head_detected_entered(area: Area2D) -> void:
	if area is AreaFluid && area.is_in_group(&"area_swimmable"):
		_character.remove_from_group(&"state_swimming_to_jumping")

func _on_head_detected_exited(area: Area2D) -> void:
	if area is AreaFluid && area.is_in_group(&"area_swimmable"):
		_character.add_to_group(&"state_swimming_to_jumping")

func _on_body_detected_area(area: Area2D) -> void:
	if area is AreaFluid && area.is_in_group(&"area_swimmable"):
		_character.add_to_group(&"state_swimming")

func _on_body_detected_exited(area: Area2D) -> void:
	if area is AreaFluid && area.is_in_group(&"area_swimmable"):
		_character.remove_from_group(&"state_swimming")
