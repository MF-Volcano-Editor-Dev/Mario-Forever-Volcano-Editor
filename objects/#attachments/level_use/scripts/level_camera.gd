class_name LevelCamera extends Classes.HiddenCamera2D

## A [Camera2D] used to focus on the characters
##
## [b]Note:[/b] This camera focuses on the average global position of each character,
## and doesn't support auto-screen-splitting system

@export_category("Level Camera")
@export_group("Section Switching")
## Mode of the camera when a character enters the area of this camera.
## This is used for multisectional levels like you have a secret room,
## and some levels that needs smooth transferring between different part of the level.[br]
## If you select the "Hard", then the camera will be IMMEDIATELY current, while choosing "Smooth"
## will generate a smooth transferring until it reaches the characters' average global position.[br]
## [br]
## [b]Note:[/b] This property takes effect ONLY WHEN the camera's [method Node._ready] is called.
@export_enum("None", "Hard", "Smooth") var section_switching_mode: int = 0
## Speed of the camera under the section switching mode "Smooth". See [member section_switching_mode].
@export_range(0, 64, 0.001, "suffix:px/s") var smooth_speed: float = 16

#region == References ==
@onready var camera_area: Area2D = $CameraArea
@onready var camera_area_shape: CollisionShape2D = $CameraArea/CollisionShape2D
#endregion


func _ready() -> void:
	if !section_switching_mode:
		return
	
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


#region == Camera methods ==
## Makes the camera focus on the average global position of characters.
func focus() -> void:
	global_position = CharactersManager2D.get_character_data_getter().get_average_global_position(global_position)

## Updates the detection of camera section immediately.
## This is used when you changed the view rect of the camera. See [method get_view_rect].
func update_camera_area_transform() -> void:
	var view_rect := get_view_rect()
	if camera_area_shape.shape:
		camera_area_shape.shape.size = view_rect.size
	camera_area.global_position = view_rect.get_center().rotated(global_rotation)

## Returns the [Rect2] of the borders within which the camera can move.[br]
## The rectangle starts from ([member Camera2D.limit_left], [member Camera2D.limit_top]) to ([member Camera2D.limit_right], [member Camera2D.limit_bottom]).
func get_view_rect() -> Rect2:
	return Rect2(limit_left, limit_top, limit_right - limit_left, limit_bottom - limit_top)
#endregion


#region == Camera section ==
func _camera_area_detection(area: Area2D) -> void:
	if is_current() && enabled: # CAUTION: This requires the camera's enabled to be true
		return
	
	var pl := area.get_parent() as CharacterEntity2D # Gets the character entering into the camera's view
	if pl:
		await _smooth_transition() # Smoothing process
		make_current()
#endregion


#region == Smooth ==
#func _smooth_initialization() -> void:
	#if !is_current():
		#return
	#
	#var pse := position_smoothing_enabled
	#var rse := rotation_smoothing_enabled
	#
	#position_smoothing_enabled = false
	#rotation_smoothing_enabled = false
	#
	#reset_smoothing()
	#await get_tree().process_frame
	#
	#position_smoothing_enabled = pse
	#rotation_smoothing_enabled = rse

func _smooth_transition() -> void:
	if section_switching_mode != 1:
		return
	
	var pre := get_viewport().get_camera_2d() # Gets previous camera
	var sms := Camera2D.new() # Prepares transitional camera
	add_sibling(sms) # Add the transitional camera to the tree
	sms.global_position = pre.get_screen_center_position() # Initializes the position of it to the center of the screen
	sms.limit_left = mini(pre.limit_left, limit_left) # Makes the area of movement of the camera the blending of both camera fields
	sms.limit_right = maxi(pre.limit_right, limit_right)
	sms.limit_top = mini(pre.limit_top, limit_top)
	sms.limit_bottom = maxi(pre.limit_bottom, limit_bottom)
	sms.make_current() # Makes the camera current
	
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
		await get_tree().process_frame # Makes the loop processed every frame
	sms.global_position = get_screen_center_position() # Fresh the global position of the transitional camera
	
	# Transitional camera - player locating
	while true:
		# Gets the average global position of the characters
		var campos := CharactersManager2D.get_character_data_getter().get_average_global_position(sms.global_position)
		if campos.is_equal_approx(sms.global_position): # and breaks the loop if the value is the same as the transitional camera's global position
			break
		var spd := smooth_speed * Process.get_delta(self)
		sms.global_position = sms.global_position.lerp(campos, spd) # Moves the transitional camera to the character's average global position
		if sms.global_position.round().is_equal_approx(campos.round()):
			break
		await get_tree().process_frame # Makes the loop processed every frame
	
	sms.queue_free() # Destroy the transitional camera; transition completed
#endregion
