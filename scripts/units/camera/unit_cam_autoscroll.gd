@tool
class_name AutoScrollCamera2D extends GameCamera2D

## Path to [PathFollow2D] to which the camera is going to track the global position.
@export_node_path("PathFollow2D") var camera_follower_path: NodePath = ^".."
## Margin to push the character at the edge of the screen.
@export_range(-32, 32, 0.001, "suffix:px") var margin: float = 16

@onready var _camera_follower: PathFollow2D = get_node_or_null(camera_follower_path) as PathFollow2D


#region == Property Overriders ==
func _init_overridden_properties() -> void:
	super()
	focus_characters = false
#endregion


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if focus_process_mode != CAMERA2D_PROCESS_IDLE:
		return
	if _camera_follower:
		global_position = _camera_follower.global_position
	_player_edgeblock.call_deferred()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if focus_process_mode != CAMERA2D_PROCESS_PHYSICS:
		return
	if _camera_follower:
		global_position = _camera_follower.global_position
	_player_edgeblock.call_deferred()


func _player_edgeblock() -> void:
	var width := get_viewport_rect().size.x # Viewport width
	var canvas_rot := get_viewport_transform().get_rotation() # Canvas rotation
	print(canvas_rot)
	var characters: Array[Character] = Character.Getter.get_characters(get_tree())
	for i in characters:
		if !get_limit_rect().has_point(i.global_position):
			continue
		var pposx := i.get_global_transform_with_canvas().get_origin().x ## X position in canvas
		while pposx < margin && !i.is_on_wall():
			i.global_position += Vector2.RIGHT.rotated(i.canvas_rot)
		while pposx > width - margin && !i.is_on_wall():
			i.global_position += Vector2.LEFT.rotated(i.canvas_rot)
		
		# Character being squeezed to death
		pposx = i.get_global_transform_with_canvas().get_origin().x
		if pposx < -margin || pposx > width + margin:
			i.die()

#region == Setgets ==
func set_focus_characters(value: bool) -> void:
	if value:
		push_warning("AutoScrollCamera2D shouldn't get this value turned on! See the documentation of GameCamera2D.")
	focus_characters = false
#endregion
