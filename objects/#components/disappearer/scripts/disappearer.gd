extends Component

## Emitted when the body disappears
signal disappeared

@export_category("Disappearer")
@export_range(0.01, 20, 0.001, "suffix:s") var duration: float = 0.25
@export var delete_deeply: bool = true
@export_group("Disability")
@export_flags("Process", "Physics Process") var disable_root_processes: int = 0b11

var _stop_delete: bool


func disappear_transparent() -> void:
	if disabled || !root is Node2D:
		return
	
	_disable_processes_on_root()
	
	var tw: Tween = root.create_tween().set_trans(Tween.TRANS_SINE)
	tw.tween_property(root, ^"modulate:a", 0, duration)
	
	await tw.finished
	
	disappeared.emit()
	_delete()


func disappear_swirl() -> void:
	if disabled || !root is Node2D:
		return
	
	_disable_processes_on_root()
	
	var rt: float = root.rotation
	var tw: Tween = root.create_tween().set_trans(Tween.TRANS_SINE).set_parallel(true)
	tw.tween_property(root, ^"rotation", rt + [TAU, -TAU].pick_random(), duration)
	tw.tween_property(root, ^"modulate:a", 0, duration)
	
	await tw.finished
	
	disappeared.emit()
	_delete()


func disappear_swirl_down() -> void:
	if disabled || !root is Node2D:
		return
	
	_disable_processes_on_root()
	
	var rt: float = root.rotation
	var tw: Tween = root.create_tween().set_trans(Tween.TRANS_SINE).set_parallel(true)
	tw.tween_property(root, ^"rotation", rt + [TAU, -TAU].pick_random(), duration)
	tw.tween_property(root, ^"scale", Vector2.ZERO, duration)
	
	await tw.finished
	
	disappeared.emit()
	_delete()


func disappear_jump(height: float = 64) -> void:
	if disabled || !root is Node2D:
		return
	
	_disable_processes_on_root()
	
	var pos: Vector2 = root.position
	var scl: Vector2 = root.scale
	var dir: Vector2 = Vector2.UP.rotated(root.rotation)
	var tw: Tween = root.create_tween().set_parallel(true)
	tw.tween_property(root, ^"position", pos + dir * height, duration / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(root, ^"scale", scl * 1.25 * Vector2(1, 1.25), duration / 2).set_trans(Tween.TRANS_SINE)
	tw.chain().tween_property(root, ^"position", pos, duration / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(root, ^"scale", Vector2(0, 0.5), duration / 2).set_trans(Tween.TRANS_SINE)
	
	await tw.finished
	
	disappeared.emit()
	_delete()


func stop_disappearance() -> void:
	_stop_delete = true


func _disable_processes_on_root() -> void:
	if !root:
		return
	
	if (disable_root_processes >> 0) & 1:
		root.set_process(false)
	if (disable_root_processes >> 1) & 1:
		root.set_physics_process(false)


func _delete() -> void:
	if !root:
		return
	elif _stop_delete:
		_stop_delete = false
		return
	
	if delete_deeply:
		root.get_parent().remove_child.call_deferred(root)
	else:
		root.queue_free()
