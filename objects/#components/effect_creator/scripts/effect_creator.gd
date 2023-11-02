extends Marker2D

## Emitted when the effect is finished
signal effect_finished

@export_category("Effect Creator")
@export var effect: PackedScene

@onready var root: Node2D = get_parent()


func create_effect(times: int = 1, duration: float = 1) -> void:
	if !effect:
		return
	
	for i in times:
		var e := effect.instantiate()
		if !e is Node2D:
			e.queue_free()
			return
		
		e = e as Node2D
		root.add_sibling.call_deferred(e)
		e.global_transform = global_transform
		
		if times > 1 && duration > 0:
			await get_tree().create_timer(duration).timeout
	
	effect_finished.emit()
