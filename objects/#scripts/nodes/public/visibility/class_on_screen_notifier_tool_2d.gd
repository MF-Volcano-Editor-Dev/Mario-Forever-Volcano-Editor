@tool
class_name OnScreenNotifierTool2D extends VisibleOnScreenNotifier2D

## Class works the same as [VisibleOnScreenNotifier2D], but more friendly
## to selection and preview.
##
## [b]Note:[/b] This will automatically set [member VisibleOnScreenNotifier2D.rect] to [Rect2](), which
## helps the developer to select the node on its actual area rather than on the one covered
## by the [VisibleOnScreenNotifier2D]. You can set [member actual_rect] to set its [member VisibleOnScreenNotifier2D.rect]
## in the runtime.[br]
## [br]
## See [class OnScreenEnablerTool2D]

## Actual [member VisibleOnScreenNotifier2D.rect]
@export var actual_rect: Rect2 = Rect2(-16, -16, 32, 32):
	set(value):
		actual_rect = value
		queue_redraw()
## If [code]true[/code], then draw a rectable of [member actual_detection_area]
@export var actual_rect_draw: bool:
	set(value):
		actual_rect_draw = value
		queue_redraw()
## Color of the [member actual_rect] drawn in the editor
@export var actual_rect_color: Color = Color(0.3, 0.4, 0.6, 0.5):
	set(value):
		actual_rect_color = value
		queue_redraw()


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		if rect != Rect2():
			rect = Rect2()
	elif rect != actual_rect:
		rect = actual_rect
	queue_redraw()

func _draw() -> void:
	if !Engine.is_editor_hint() || !actual_rect_draw:
		return
	draw_rect(actual_rect, actual_rect_color)
