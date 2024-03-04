class_name BumpBlock2D extends AnimatableBody2D

## Abstract class used for blocks that are interactable with other [PhysicsBody2D] by bumping.
##
## 

signal bumped ## Emitted when the block gets bumped.
signal bump_over ## Emitted when the bumping is over.

@export_node_path("ShapeCast2D") var detector_path: NodePath
@export_range(0, 45, 0.001, "degrees") var tolerance: float = 45
@export_range(-180, 180, 0.001, "degrees") var up_direction_angle: float = 0

@onready var detector: ShapeCast2D = get_node(detector_path)

var _is_on_bumping: bool


func _physics_process(_delta: float) -> void:
	if !detector:
		return
	
	for i in detector.get_collision_count():
		var col := detector.get_collider(i) as Node2D
		var col_pos := detector.get_collision_point(i)
		_bump(col, col_pos)


## [code]virtual[/code] Called on getting bumped by a bumper.
func _bump_process(_bumper: Node2D, _touch_spot: Vector2) -> void:
	get_tree().create_timer(0.1, false).timeout.connect(func() -> void:
		bump_over.emit()
	)
	await bump_over
	


func _bump(bumper: Node2D, _touch_spot: Vector2) -> void:
	if !bumper:
		return
	if _is_on_bumping:
		return
	
	_is_on_bumping = true
	
	var up := Vector2.UP.rotated(global_rotation + deg_to_rad(up_direction_angle))
	var dir_to_c := _touch_spot.direction_to(global_position)
	var tol := deg_to_rad(tolerance)
	
	if bumper.is_in_group(&"hit_block"):
		bumped.emit()
	elif bumper.is_in_group(&"hit_block_head") && dir_to_c.dot(up) > cos(tol):
		bumped.emit()
	elif bumper.is_in_group(&"hit_block_feet") && dir_to_c.dot(-up) > cos(tol):
		bumped.emit()
	elif bumper.is_in_group(&"hit_block_side") && (dir_to_c.dot(up.orthogonal()) > cos(tol) || dir_to_c.dot(-up.orthogonal()) > cos(tol)):
		bumped.emit()
	
	_bump_process(bumper, _touch_spot)


## Called in [method _bump_process] to restore the status of being bumped.
func restore_bump() -> void:
	_is_on_bumping = false
