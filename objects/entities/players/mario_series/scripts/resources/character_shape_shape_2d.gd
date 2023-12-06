class_name CharacterShape2D extends Resource

## Resource that used to override the collision shape of [CharacterEntity2D]
##
##

@export_category("Character Shape")
@export var shape: Shape2D
@export var position: Vector2:
	set(value):
		_trans = true
		transform.origin = position
@export_range(-180, 180, 0.001, "degrees") var rotation: float:
	set(value):
		_trans = true
		transform.x = Vector2.RIGHT.rotated(deg_to_rad(rotation))
		transform.y = Vector2.DOWN.rotated(deg_to_rad(rotation))
@export var scale: Vector2 = Vector2(1, 1):
	set(value):
		_trans = true
		transform.x *= value.x
		transform.y *= value.y

var _trans: bool
var transform: Transform2D:
	set(value):
		if _trans:
			return
		transform = value
		position = transform.get_origin()
		rotation = rad_to_deg(transform.get_rotation())
		scale = transform.get_scale()


func _init() -> void:
	scale = scale # Triggers the scale's setter
