class_name CharacterShape2D extends Resource

## Resource that used to override the collision shape of [CharacterEntity2D]
##
##

@export_category("Character Shape")
@export var shape: Shape2D
@export var position: Vector2
@export_range(-180, 180, 0.001, "degrees") var rotation: float
@export var scale: Vector2 = Vector2.ONE
@export_range(-90, 90, 0.001, "degrees") var skew: float


func _init() -> void:
	scale = scale # Triggers the scale's setter


#region == Transform ==
func set_transform(trans: Transform2D) -> void:
	position = trans.get_origin()
	rotation = rad_to_deg(trans.get_rotation())
	scale = trans.get_scale()
	skew = rad_to_deg(trans.get_skew())

func get_transform() -> Transform2D:
	return Transform2D(deg_to_rad(rotation), scale, deg_to_rad(skew), position)
#endregion
