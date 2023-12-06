class_name OnScreenNotifierToolDir2D extends OnScreenNotifierTool2D

## Class used to detect if the node leaves from specific sides of the screen
##
##

signal screen_exited_from_specific_sides ## Emitted when the node is leaving from specific sides of the screen

## Defines from which sides of the screen the detection will process.
@export_flags("Left", "Right", "Top", "Bottom") var specific_screen_sides: int


func _init() -> void:
	set_physics_process(false)
	set_process(false)

func _ready() -> void:
	screen_entered.connect(set_process.bind(false))
	screen_exited.connect(set_process.bind(true))

func _process(_delta: float) -> void:
	var viewport_rect := get_viewport_rect()
	var node_gpos := get_global_transform_with_canvas().get_origin()
	# From: (The order of the sides matches the order of lines of codes following)
	# Left,
	# Right,
	# Top,
	# Bottom
	if (bool(specific_screen_sides & 1) && node_gpos.x < viewport_rect.position.x) || \
		(bool((specific_screen_sides >> 1) & 1) && node_gpos.x > viewport_rect.end.x) || \
		(bool((specific_screen_sides >> 2) & 1) && node_gpos.y > viewport_rect.position.x) || \
		(bool((specific_screen_sides >> 3) & 1) && node_gpos.y > viewport_rect.end.y): 
			screen_exited_from_specific_sides.emit()
