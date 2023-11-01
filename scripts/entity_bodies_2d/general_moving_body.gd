extends EntityBody2D

@export_category("General Moving Body")
@export_enum("None", "Look at Player X", "Loook at Player Y") var initial_moving_direction: int


func _ready() -> void:
	if velocity.x:
		if initial_moving_direction > 0:
			var npl := PlayersManager.get_nearest_player(global_position)
			if !npl:
				return
			
			var ppos: float = (global_transform.basis_xform(npl.global_position))[initial_moving_direction - 1]
			var pos: float = global_transform.affine_inverse().basis_xform(global_position)[initial_moving_direction - 1]
			
			if ppos - pos:
				velocity[initial_moving_direction - 1] *= signf(ppos - pos)


func _physics_process(_delta: float) -> void:
	move_and_slide()
