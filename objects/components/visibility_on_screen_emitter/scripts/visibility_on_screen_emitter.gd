extends VisibleOnScreenNotifier2D

## Emitted when the node is out of a border of screen
signal stayed_out_of_border

@export_category("Visibility On Screen Emitter")
## Options to decided from which edge(s) of border will [signal stayed_out_of_border] be emitted
@export_flags("Left", "Right", "Top", "Bottom") var detected_screen_borders: int

@onready var root: Node2D = get_parent()


func _ready() -> void:
	visible = true
	screen_entered.connect(set_process.bind(false))
	screen_exited.connect(set_process.bind(true))


func _process(_delta: float) -> void:
	var left: bool = detected_screen_borders & 0b0001 == 0b0001
	var right: bool = detected_screen_borders & 0b0010 == 0b0010
	var top: bool = detected_screen_borders & 0b01000 == 0b0100
	var bottom: bool = detected_screen_borders & 0b1000 == 0b1000
	
	var canvas_pos := get_global_transform_with_canvas().get_origin()
	var viewsize := get_viewport_rect().size
	
	if (left && canvas_pos.x < 0) || \
	(right && canvas_pos.x > viewsize.x) || \
	(top && canvas_pos.y < 0) || \
	(bottom && canvas_pos.y > viewsize.y):
		stayed_out_of_border.emit()
