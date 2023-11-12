extends Camera2D

## A [Camera2D] used to focus on the players
##
##

@export_category("Level Camera")
@export_group("Editor")
@export_subgroup("Limitation Preview")
@export var limit_border_color: Color = Color.MEDIUM_SPRING_GREEN
@export_range(0, 16, 0.001, "suffix:px") var limit_border_width: float = 4
@export_group("Smooth")
@export var smooth_when_entering: bool
@export_range(0, 64, 0.001, "suffix:px/s") var smooth_speed: float = 16

@onready var camera_area: Area2D = $CameraArea
@onready var camera_area_shape: CollisionShape2D = $CameraArea/CollisionShape2D


func _ready() -> void:
	var shape := RectangleShape2D.new()
	
	camera_area.area_entered.connect(_camera_area_detection)
	camera_area_shape.set_deferred(&"shape", shape)
	update_camera_area_transform.call_deferred()


func _process(_delta: float) -> void:
	if !is_current():
		return
	
	# Delayed for one process frame to make sure the camera
	# focus on the players' average global position accurately
	await get_tree().process_frame
	
	var campos := PlayersManager.get_average_global_position(self)
	if campos == Vector2.INF:
		return
	
	global_position = campos


func update_camera_area_transform() -> void:
	var view_rect := get_view_rect()
	if camera_area_shape.shape:
		camera_area_shape.shape.size = view_rect.size
	camera_area.global_position = view_rect.get_center().rotated(global_rotation)


func get_view_rect() -> Rect2:
	return Rect2(limit_left, limit_top, limit_right - limit_left, limit_bottom - limit_top)


#region Camera Area
func _camera_area_detection(area: Area2D) -> void:
	if is_current() && enabled:
		return
	enabled = true
	
	var pl := area.get_parent() as EntityPlayer2D
	if pl:
		await _smooth_transition()
		make_current()
#endregion


#region Smooth
func _smooth_initialization() -> void:
	if !is_current():
		return
	
	var pse := position_smoothing_enabled
	var rse := rotation_smoothing_enabled
	
	position_smoothing_enabled = false
	rotation_smoothing_enabled = false
	
	reset_smoothing()
	await get_tree().process_frame
	
	position_smoothing_enabled = pse
	rotation_smoothing_enabled = rse


func _smooth_transition() -> void:
	if !smooth_when_entering:
		return
	
	# Camera linking and transitional camera creating
	var pre := get_viewport().get_camera_2d()
	var sms := Camera2D.new()
	
	# Prepare camera
	add_sibling(sms)
	sms.global_position = pre.get_screen_center_position()
	sms.limit_left = mini(pre.limit_left, limit_left)
	sms.limit_right = maxi(pre.limit_right, limit_right)
	sms.limit_top = mini(pre.limit_top, limit_top)
	sms.limit_bottom = maxi(pre.limit_bottom, limit_bottom)
	sms.make_current()
	
	# Transitional Camera - Margin shrinking
	while sms.is_current():
		var spd := smooth_speed * Process.get_delta(self)
		
		if sms.limit_left < limit_left:
			sms.limit_left = ceili(lerp(sms.limit_left, limit_left, spd))
		if sms.limit_right > limit_right:
			sms.limit_right = floori(lerp(sms.limit_right, limit_right, spd))
		if sms.limit_top < limit_top:
			sms.limit_top = ceili(lerp(sms.limit_top, limit_top, spd))
		if sms.limit_bottom > limit_bottom:
			sms.limit_bottom = floori(lerp(sms.limit_bottom, limit_bottom, spd))
		
		if (
			is_equal_approx(sms.limit_left, limit_left) &&
			is_equal_approx(sms.limit_right, limit_right) &&
			is_equal_approx(sms.limit_top, limit_top) &&
			is_equal_approx(sms.limit_bottom, limit_bottom)
		):
			break
		
		await get_tree().process_frame
	
	sms.global_position = get_screen_center_position()
	
	# Transitional Camera - Player locating
	while sms.is_current():
		var campos := PlayersManager.get_average_global_position(self)
		if campos == Vector2.INF:
			break
		
		var spd := smooth_speed * Process.get_delta(self)
		sms.global_position = sms.global_position.lerp(campos, spd)
		if sms.global_position.round().is_equal_approx(campos.round()):
			break
		
		await get_tree().process_frame
	
	# Destroy the transitional camera
	sms.queue_free()
#endregion
