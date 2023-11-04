extends EntityBody2D

@export_category("General Moving Body")
@export_enum("None", "Look at Player") var initial_moving_direction: int


func _ready() -> void:
	if speed && initial_moving_direction == 1:
		var npl := PlayersManager.get_nearest_player(global_position)
		if !npl:
			return
		
		var dir := Transform2DAlgo.get_direction_to_regardless_transform(global_position, npl.global_position, global_transform)
		if dir:
			speed *= dir


func _physics_process(_delta: float) -> void:
	move_and_slide()
