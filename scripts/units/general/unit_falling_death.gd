extends Node

## Unit used to make a character die when he/she falls out of the screen.
##
## [b]Note:[/b] Each level can contain ONLY ONE of this.

@export_category("Unit Falling Death")
@export_range(-1, 1, 0.001, "or_less", "or_greater", "hide_slider", "suffix:px") var margin: float = 48


func _process(_delta: float) -> void:
	var characters: Array[Character] = Character.Getter.get_characters(get_tree())
	for i in characters:
		var cvs_pos: Vector2 = i.get_global_transform_with_canvas().get_origin() # Canvas position
		var ga: float = i.get_gravity_vector().angle() # Gravity angle
		var wh: Vector2 = i.get_viewport_rect().size # Viewport size
		
		if (cvs_pos.x < -margin && (ga >= 3*PI/4 || ga < -3*PI/4)) || \
			(cvs_pos.x > wh.x + margin && ga >= -PI/4 && ga < PI/4) || \
			(cvs_pos.y > wh.y + margin && ga >= PI/4 && ga < 3*PI/4) || \
			(cvs_pos.y < -margin && ga > -3*PI/4 && ga < -PI/4):
				i.die()
