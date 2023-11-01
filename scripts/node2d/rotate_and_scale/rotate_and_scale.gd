extends Node2D

@export_category("Rotation and Scale")
@export var accordance: Node
@export_group("Scale")
@export_subgroup("X")
@export var scale_x_accordance: String
@export var scale_x_basis: float = 1.0
@export_subgroup("Y")
@export var scale_y_accordance: String
@export var scale_y_basis: float = 1.0
@export_group("Rotation")
@export_range(-18000, 18000, 0.001, "suffix:°/s²") var rotation_speed: float
@export var rotation_direction_accordance: String

var _scale: Array = [1.0, 1.0]
var _rotation_direction


func _ready() -> void:
	if accordance:
		update_scale_accordance()
		update_rotation_direction_accordance()

func _process(delta: float) -> void:
	_scale_process()
	_rotation_process(delta)


func _scale_process() -> void:
	scale = Vector2(_scale[0] * scale_x_basis, _scale[1] * scale_y_basis)


func _rotation_process(delta: float) -> void:
	rotate(deg_to_rad(rotation_speed) * delta * _rotation_direction)


func update_scale_accordance() -> void:
	_scale = [
		accordance.get_indexed(scale_x_accordance),
		accordance.get_indexed(scale_y_accordance),
	]
	for i in _scale.size():
		_scale[i] = signf(_scale[i]) if _scale[i] is float else 1.0


func update_rotation_direction_accordance() -> void:
	_rotation_direction = accordance.get_indexed(rotation_direction_accordance)
	_rotation_direction = signf(_rotation_direction) if _rotation_direction is float else 1.0
