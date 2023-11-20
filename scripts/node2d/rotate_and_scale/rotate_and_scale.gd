extends Node2D

@export_category("Rotation and Scale to EntityBody2D")
@export var accordance: Node
@export_group("Scale")
@export_subgroup("X")
@export_placeholder("Input prop:sub_prop if possible") var scale_x_path: String
@export var scale_x_basis: float = 1.0
@export_subgroup("Y")
@export_placeholder("Input prop:sub_prop if possible") var scale_y_path: String
@export var scale_y_basis: float = 1.0
@export_group("Rotation")
@export_placeholder("Input prop:sub_prop if possible") var rotation_direction_path: String
@export_range(-18000, 18000, 0.001, "suffix:°/s") var rotation_speed: float


func _process(delta: float) -> void:
	if !accordance:
		return
	
	var scl := Vector2.ONE
	var sclx = accordance.get_indexed(scale_x_path)
	var scly = accordance.get_indexed(scale_y_path)
	if sclx is float && !is_zero_approx(sclx):
		scl.x *= scale_x_basis * signf(sclx)
	if scly is float && !is_zero_approx(scly):
		scl.y *= scale_y_basis * signf(scly)
	scale = scl
	
	var rsdir := 1
	var rsdirpth = accordance.get_indexed(rotation_direction_path)
	if rsdirpth is float && !is_zero_approx(rsdirpth):
		rsdir *= int(signf(rsdirpth))
	
	rotate(deg_to_rad(rotation_speed) * delta * rsdir)
