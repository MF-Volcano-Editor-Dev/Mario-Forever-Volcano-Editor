extends Component

## Emitted when the body disappears
signal disappeared

@export_category("Disappearer")
@export_range(0.01, 20, 0.001, "suffix:s") var duration: float = 0.25
@export var delete_deeply: bool = true
@export_group("Disability")
@export_flags("Process", "Physics Process") var disable_root_processes: int = 0b11


func disappear_transparent() -> void:
	if disabled || !root is Node2D:
		return
	
	_disable_processes_on_root()
	
	await Effects2D.transparentize(root, duration).finished
	
	disappeared.emit()
	_delete()


func disappear_swirl() -> void:
	if disabled || !root is Node2D:
		return
	
	_disable_processes_on_root()
	
	await Effects2D.swirl_and_transparentize(root, duration, TAU).finished
	
	disappeared.emit()
	_delete()


func disappear_swirl_down() -> void:
	if disabled || !root is Node2D:
		return
	
	_disable_processes_on_root()
	
	await Effects2D.swirl_down(root, duration, TAU).finished
	
	disappeared.emit()
	_delete()


func disappear_slime(height: float = 64) -> void:
	if disabled || !root is Node2D:
		return
	
	_disable_processes_on_root()
	
	await Effects2D.slime(root, duration, height).finished
	
	disappeared.emit()
	_delete()


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
	
	if delete_deeply:
		root.get_parent().remove_child.call_deferred(root)
	else:
		root.queue_free()
