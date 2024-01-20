class_name MarioPowerup extends Node2D

signal powerup_entered ## Emitted when the powerup becomes current.
signal powerup_exited ## Emitted when the powerup exits from being current.

@export var mario: Mario
@export var powerup_id: StringName = &"small"
@export_group("References")
@export var collision_shapes: Array[CollisionShape2D]
@export_group("Features")
@export var is_small: bool = true

@onready var _character: Character = get_parent() as Character

## [code]virtual[/code], [code]mutable[/code] Called when the powerup becomes current.
func _powerup_entered() -> void:
	powerup_entered.emit()
	if !collision_shapes.is_empty():
		set_shapes_for_character.call_deferred()

## [code]virtual[/code], [code]mutable[/code] Called when the powerup exits from being current.
func _powerup_exited() -> void:
	powerup_exited.emit()


## Sets the shapes for the character.[br]
## [br]
## [b]Note:[/b] This is done with [PhysicsServer2D]
func set_shapes_for_character() -> void:
	(func() -> void:
		for i in collision_shapes:
			if !i:
				continue
			var crid: RID = _character.get_rid()
			var srid: RID = i.shape.get_rid() if i.shape else RID()
			var index: int = collision_shapes.find(i)
			# Adds shapes if there is no any shapes created for the character directly
			if PhysicsServer2D.body_get_shape_count(crid) < collision_shapes.size():
				PhysicsServer2D.body_add_shape(crid, srid, i.transform)
			# Uses server to help with setting the shapes
			# so that even the collision shapes are not the direct child of the character.
			# the character still enjoys them as it should have them.
			PhysicsServer2D.body_set_shape(crid, index, srid)
			PhysicsServer2D.body_set_shape_as_one_way_collision(crid, index, i.one_way_collision, i.one_way_collision_margin)
			PhysicsServer2D.body_set_shape_disabled(crid, index, i.disabled)
			PhysicsServer2D.body_set_shape_transform(crid, index, i.transform)
	).call_deferred()
