extends AnimatedSprite2D

@export_category("Liquid Group")
## Fluid group that makes the spray able to be generated
@export var fluid_group: StringName
## Depth of pulling to the surface of fluid
@export_range(0, 64) var depth: int = 16

@onready var _rotator: ShapeCast2D = $Rotator
@onready var _push_or_pull: ShapeCast2D = $PushOrPull


func _ready() -> void:
	_rotator.force_shapecast_update()
	# Able to appear
	# Rotator detects with a longer radius than PushOrPull
	if _rotator.is_colliding():
		# Rotation
		var rcol: Node2D = _rotator.get_collider(0)
		if rcol && rcol.is_in_group(fluid_group):
			global_rotation = _rotator.get_collision_normal(0).angle() + PI/2
		
		_push_or_pull.force_shapecast_update()
		# Push
		if _push_or_pull.is_colliding():
			var pcol: Node2D = _push_or_pull.get_collider(0)
			while pcol && pcol.is_in_group(fluid_group):
				global_position += Vector2.UP.rotated(global_rotation)
				# Updates information about the collider
				pcol = _get_collider(_push_or_pull, 0)
		# Pull
		else:
			var pcol: Node2D = null
			while !pcol || !pcol.is_in_group(fluid_group):
				global_position += Vector2.DOWN.rotated(global_rotation)
				# Updates information about the collider
				pcol = _get_collider(_push_or_pull, 0)
	# Or disappear at once
	else:
		queue_free()
		return
	
	# Effect for disappearance
	animation_finished.connect(queue_free)

# Auto updates cast and returns the collider (if existing).
func _get_collider(caster: ShapeCast2D, index: int) -> Node2D:
	caster.force_shapecast_update()
	if !caster.is_colliding():
		return null
	return caster.get_collider(index) as Node2D
