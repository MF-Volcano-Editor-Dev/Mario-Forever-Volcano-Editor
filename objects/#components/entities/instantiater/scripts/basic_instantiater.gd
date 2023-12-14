class_name BasicInstantiater2D extends Instantiater2D

## Class that instantiates the nodes in the simplest way

@export_category("Basic Instantiater")
@export var instance: PackedScene
@export var instance_offset: Vector2


## Instantiates the packed scene and create it into the current [SceneTree]
func create_instance() -> void:
	instantiate(instance, instance_offset)
