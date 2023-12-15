class_name EntityBodyShooter2D extends Instantiater2D

@export_category("Entity Body Shooter")
@export var body: PackedScene
@export var body_offset: Vector2
@export_group("Velocity")
@export var velocity: Vector2
@export var velocity_randomizer: Vector4
@export_group("Direction")
@export var direction_property_path: NodePath

var _direction_node: Node
var _direction_property: NodePath


func _ready() -> void:
	if direction_property_path.is_empty():
		return
	_direction_node = get_node_or_null(NodePath(direction_property_path.get_concatenated_names()))
	_direction_property = NodePath(direction_property_path.get_concatenated_subnames())


#region == Instantiation ==
func instantiate(packed_scene: PackedScene, offset: Vector2 = Vector2.ZERO) -> EntityBody2D:
	return super(packed_scene, offset) as EntityBody2D

# Covarianted function
func get_prepared_instance(packed_scene: PackedScene) -> EntityBody2D:
	var ins := packed_scene.instantiate()
	if !ins is EntityBody2D:
		ins.queue_free() # Don't forget to manually remove the instance that is not a Node2D
		return null
	return ins as EntityBody2D

func shoot() -> void:
	var entity := instantiate(body, body_offset)
	var direction = _direction_node.get_indexed(_direction_property)
	var rand_velocity := Vector2(velocity.x + randf_range(velocity_randomizer.x, velocity_randomizer.z), velocity.y + randf_range(velocity_randomizer.y, velocity_randomizer.w)) * float(direction if (direction is float || direction is int) && direction != 0 else 1.0)
	entity.velocity = rand_velocity.rotated(global_rotation)
#endregion
