extends Classes.ItemComponent

## Emitted when the item appears
signal item_appeared

@export_category("Item Appearing")
@export_group("Appearance")
@export_range(0, 10, 0.001, "suffix:s") var appearing_duration: float = 1
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px") var apperaing_final_y_pos: float = 32


func _ready() -> void:
	super()
	
	item_hit_out.connect(_on_item_hit_out)


func _on_item_hit_out(hitting_direction: Vector2) -> void:
	if !root is Node2D:
		return
	
	root.set_process(false)
	root.set_physics_process(false)
	
	var gpos: Vector2 = root.global_position
	var tw := root.create_tween()
	tw.tween_property(root, ^"global_position", gpos + Vector2.UP.rotated(root.global_rotation) * apperaing_final_y_pos, appearing_duration)
	await tw.finished
	
	root.set_process(true)
	root.set_physics_process(true)
	item_appeared.emit()
