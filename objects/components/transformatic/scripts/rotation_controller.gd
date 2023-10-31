extends Component

@export_category("Rotation Controller")
@export_range(-18000, 18000, 0.001, "or_less", "or_greater", "hide_slider", "suffix:°/s²") var rotation_speed: float
@export_enum("None", "Scale X", "Scale Y") var rotation_direction_accordance: int


func _process(delta: float) -> void:
	if !rotation_speed || !root is Node2D:
		return
	
	var rdir: float = 1.0 if rotation_direction_accordance == 0 else \
		signf(root.scale.x) if rotation_direction_accordance == 1 else \
		signf(root.scale.y)
	root.rotate(deg_to_rad(rotation_speed) * delta * rdir)
