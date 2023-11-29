extends Timer

@export_category("Effect Phantom Creator")
## Path of root node
@export_node_path("Node2D") var root_path: NodePath = ^".."
@export_group("Phantom")
## [Node2D] to track as phantom
@export var phantom: Node2D
@export_flags("Y Sort Enabled", "Z Index", "Z as Relative") var phantom_visual_inheritances: int = 0b110
@export_range(0, 10, 0.001, "suffix:s") var phantom_duration_without_tween: float = 0.5
@export_subgroup("Tween Phantom")
@export var phantom_tween: bool = true
@export_range(0, 10, 0.001, "suffix:s") var phantom_duration_alpha_tween: float = 0.4

@onready var root: Node2D = get_node_or_null(root_path) as Node2D


func _ready() -> void:
	timeout.connect(
		func() -> void:
			if !root || !phantom:
				return
			
			var curscn := get_tree().current_scene
			var ph := phantom.duplicate() as Node2D
			curscn.add_sibling(ph)
			ph.global_transform = root.global_transform
			
			if phantom_visual_inheritances & 0b001 == 0b001:
				ph.y_sort_enabled = root.y_sort_enabled
			if phantom_visual_inheritances & 0b010 == 0b010:
				ph.z_index = root.z_index - 1
			if phantom_visual_inheritances & 0b100 == 0b100:
				ph.z_as_relative = root.z_as_relative
			
			if phantom_tween:
				var tw: Tween = ph.create_tween()
				tw.tween_property(ph, ^"modulate:a", 0, phantom_duration_alpha_tween)
				tw.finished.connect(ph.queue_free)
			else:
				get_tree().create_timer(phantom_duration_without_tween, false).timeout.connect(ph.queue_free)
	)
