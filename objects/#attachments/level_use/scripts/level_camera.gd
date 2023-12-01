class_name LevelCamera extends Classes.HiddenCamera2D

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
	focus()


#region == Public methods ==
func focus() -> void:
	var campos := await CharactersManager2D.get_character_data_getter().get_average_global_position(get_tree(), global_position)
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
#endregion


#region Camera Area
func _camera_area_detection(area: Area2D) -> void:
	if is_current() && enabled:
		return
	enabled = true
	
	var pl := area.get_parent() as CharacterEntity2D
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
	
	# Gets previous camera
	var pre := get_viewport().get_camera_2d()
	# Prepares transitional camera
	var sms := Camera2D.new()
	add_sibling(sms)
	# Initializes the data of it
	sms.global_position = pre.get_screen_center_position()
	# Makes the area of movement of the camera the blending of both camera fields
	sms.limit_left = mini(pre.limit_left, limit_left) 
	sms.limit_right = maxi(pre.limit_right, limit_right)
	sms.limit_top = mini(pre.limit_top, limit_top)
	sms.limit_bottom = maxi(pre.limit_bottom, limit_bottom)
	# Makes the camera current
	sms.make_current()
	
	# Transitional camera - margin shrinking
	while true:
		var spd := smooth_speed * Process.get_delta(self)
		# Makes the border of moving area of the transitional camera smaller and more accurate
		if sms.limit_left < limit_left:
			sms.limit_left = ceili(lerp(sms.limit_left, limit_left, spd))
		if sms.limit_right > limit_right:
			sms.limit_right = floori(lerp(sms.limit_right, limit_right, spd))
		if sms.limit_top < limit_top:
			sms.limit_top = ceili(lerp(sms.limit_top, limit_top, spd))
		if sms.limit_bottom > limit_bottom:
			sms.limit_bottom = floori(lerp(sms.limit_bottom, limit_bottom, spd))
		# Till the transitional camera's borders are snapped to these of new camera.
		if (
			is_equal_approx(sms.limit_left, limit_left) &&
			is_equal_approx(sms.limit_right, limit_right) &&
			is_equal_approx(sms.limit_top, limit_top) &&
			is_equal_approx(sms.limit_bottom, limit_bottom)
		):
			break
		# Makes the loop processed every frame
		await get_tree().process_frame
	# Fresh the global position of the transitional camera
	sms.global_position = get_screen_center_position()
	
	# Transitional camera - player locating
	while true:
		# Gets the average global position of the players
		# and breaks the loop if the value is the same as
		# the transitional camera's global position
		var campos := await CharactersManager2D.get_character_data_getter().get_average_global_position(get_tree(), sms.global_position)
		if campos == sms.global_position:
			break
		
		var spd := smooth_speed * Process.get_delta(self)
		sms.global_position = sms.global_position.lerp(campos, spd)
		if sms.global_position.round().is_equal_approx(campos.round()):
			break
		# Makes the loop processed every frame
		await get_tree().process_frame
	
	# Destroy the transitional camera
	sms.queue_free()
#endregion
