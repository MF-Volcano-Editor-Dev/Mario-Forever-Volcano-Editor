class_name MarioPowerup extends Node2D

## [MarioPowerup] is used to provide sprites and behaviors for [Character], which are implemented in the form of [Node]s.
##
## This node is required to be a direct child of [Character] so that the character may detect and get access to this node together with its children.[br]
## [br]
## To provide specific data for a character that the powerup is tracking on, such as sprites and behaviors, please use relevant nodes and add them as the children of this node.

signal powerup_entered ## Emitted when the powerup becomes current.
signal powerup_exited ## Emitted when the powerup exits from being current.

## Id of the powerup.[br]
## This is used to make this node identified by the character, and gives the node an real identity of a [u]unique[/u] powerup.
@export var powerup_id: StringName = &"small"
@export_group("References")
## [CollisionShape2D]s that the node is going to set for the character.[br]
## [br]
## [b]Note:[/b] Before Godot 4.3 to be released, [CollisionShape2D] doesn't support indirect reference to a [PhysicsBody2D], which is the ancestor class of [Character] and even [Mario].
## That is to say, the [CollisionShape2D]s work only when they are direct children of it. 
## See [method set_shapes_for_character] for more details.
@export var collision_shapes: Array[CollisionShape2D]
@export_group("Physics")
## Overrides [member EntityBody2D.gravity_scale] of the character.[br]
## [br]
## [b]Note[/b]: This property works only at the moment the powerup becomes current, or the moment the value gets changed.
@export var gravity_scale_override: float = 1:
	set(value):
		gravity_scale_override = value
		if !is_instance_valid(_character):
			return
		if !_character.is_node_ready():
			return
		_character.gravity_scale = gravity_scale_override
## Overrides [member EntityBody2D.max_falling_speed] of the character.[br]
## See [member gravity_scale_override] for details
@export var max_falling_speed_override: float = 500:
	set(value):
		gravity_scale_override = value
		if !is_instance_valid(_character):
			return
		if !_character.is_node_ready():
			return
		_character.max_falling_speed = max_falling_speed_override

@onready var _character: Character = get_parent() as Character


## [code]virtual[/code], [code]mutable[/code] Called when the powerup becomes current.
func _powerup_entered() -> void:
	powerup_entered.emit()
	
	if !collision_shapes.is_empty():
		set_shapes_for_character.call_deferred()
	
	gravity_scale_override = gravity_scale_override # Triggers the setter of this property to set the value for the character
	max_falling_speed_override = max_falling_speed_override # Same as previous one

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
