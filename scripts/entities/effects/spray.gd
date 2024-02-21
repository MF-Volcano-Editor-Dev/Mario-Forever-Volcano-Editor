extends Node2D

## Spray effect
##
## [b]Note:[/b] Because of detection for being underwater and rotation, this object may heavily consume performance in a large amount.

@export_category("Liquid Group")
## Fluid group that makes the spray able to be generated
@export var fluid_group: StringName
## Depth of pulling to the surface of fluid
@export_range(0, 64) var depth: int = 16

@onready var _disappearer: ShapeCast2D = $Disappearer
@onready var _rotator: ShapeCast2D = $Rotator
@onready var _pull_or_push: ShapeCast2D = $PullOrPush
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_rotator.force_shapecast_update()
	
	if _rotator.is_colliding():
		var area := _rotator.get_collider(0) as Area2D
		if _is_colliding_with_fluid(area):
			global_rotation = _rotator.get_collision_normal(0).angle() + PI/2
		
		# Disappear underwater
		_disappearer.force_shapecast_update()
		if _disappearer.is_colliding():
			var d_area := _disappearer.get_collider(0) as Area2D
			if _is_colliding_with_fluid(d_area):
				queue_free()
				return
		
		_pull_or_push.force_shapecast_update()
		# Push
		if _pull_or_push.is_colliding():
			while _is_colliding_with_fluid_while_loop(_pull_or_push):
				global_position += Vector2.UP.rotated(global_rotation)
				_pull_or_push.force_shapecast_update()
		else:
			while !_is_colliding_with_fluid_while_loop(_pull_or_push):
				global_position += Vector2.DOWN.rotated(global_rotation)
				_pull_or_push.force_shapecast_update()
	else:
		queue_free()
		return
	
	# Effect for disappearance
	_sprite.animation_finished.connect(queue_free)


func _is_colliding_with_fluid(collider: Area2D) -> bool:
	return collider && collider.is_in_group(fluid_group)

func _is_colliding_with_fluid_while_loop(shape_caster: ShapeCast2D) -> bool:
	if !shape_caster.is_colliding():
		return false
	var area := shape_caster.get_collider(0) as Area2D
	return area && area.is_in_group(fluid_group)
