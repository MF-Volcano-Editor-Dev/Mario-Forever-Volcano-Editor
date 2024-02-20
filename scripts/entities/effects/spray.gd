extends AnimatedSprite2D

@export_category("Liquid Group")
## Liquid group that makes the spray able to be generated
@export var liquid_group: StringName
## Depth of pulling to the surface of liquid
@export_range(0, 64) var depth: int = 16

@onready var _rotator: ShapeCast2D = $Rotator


func _ready() -> void:
	_rotator.force_shapecast_update()
	if _rotator.is_colliding():
		var rcol: Node2D = _rotator.get_collider(0)
		if rcol && rcol.is_in_group(liquid_group):
			global_rotation = _rotator.get_collision_normal(0).angle() + PI/2
	
	# Effect for disappearance
	animation_finished.connect(queue_free)
