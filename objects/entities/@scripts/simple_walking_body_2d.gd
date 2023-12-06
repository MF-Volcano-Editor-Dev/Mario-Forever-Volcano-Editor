class_name SimpleWalkingEntity2D extends Classes.HiddenEntityBody2D

@export_category("Simple Walking Entity")
@export_enum("Node", "To Player", "Back to Player") var initial_direction: int = 1


func _ready() -> void:
	update_direction()

func _physics_process(_delta: float) -> void:
	move_and_slide()


func update_direction() -> void:
	if initial_direction == 0:
		return
	var nearest_character := CharactersManager2D.get_characters_getter().get_character_nearest_to(global_position)
	var dir := Transform2DAlgo.get_direction_to_regardless_transform(global_position, nearest_character.global_position, global_transform)
	velocity.x *= dir if initial_direction == 1 else -dir
