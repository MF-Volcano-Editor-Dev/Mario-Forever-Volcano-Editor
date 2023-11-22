extends Node2D

const WARPING_META_NAME: StringName = &"warp_dir"
const WARPING_STATES: Array[StringName] = [&"warping", &"no_physics", &"control_ignored", &"no_hurt", &"no_death"]

@export_category("Pipe Exit")
@export_enum("Up: 1", "Down: -1", "Left: -2", "Right: 2") var exit_direction: int = 1
@export_group("Sounds", "sound_")
@export var sound_exiting: AudioStream = preload("res://assets/sounds/power_down.wav")

@onready var pos_right: Marker2D = $PosRight
@onready var pos_left: Marker2D = $PosLeft


func _ready() -> void:
	if !ProjectSettings.get_setting("debug/shapes/collision/draw_2d_outlines"):
		visible = false


func player_exit(player: EntityPlayer2D) -> void:
	if !player.state_machine.is_state(&"warping"):
		return
	
	# Update camera
	var cam := get_viewport().get_camera_2d()
	if cam is Classes.LevelCamera:
		cam.focus()
		cam.force_update_scroll()
	
	Sound.play_sound_2d(self, sound_exiting) # Plays sound
	
	# Initial offset, original global position and target global position
	var ofs := Vector2.DOWN.rotated(global_rotation) * 60
	var gpos := (global_position if absi(exit_direction) != 2 else pos_right.global_position if exit_direction > 0 else pos_left.global_position) + ofs
	var tar := gpos - ofs
	
	# Vertical exiting: loop detection for final position to exit
	player.global_position = global_position
	while absi(exit_direction) == 1:
		player.global_position += Vector2.UP.rotated(global_rotation) * exit_direction
		if !player.test_move(player.global_transform, Vector2.ZERO):
			tar = player.global_position
			break
	player.global_position = gpos
	
	# Set warping direction on exiting from the pipe
	player.set_meta(WARPING_META_NAME, exit_direction)
	
	# Starts movement
	var tw := player.create_tween()
	tw.tween_property(player, ^"global_position", tar, 1)
	
	await tw.finished # Till the movement's ending
	
	# Remove warping states
	player.state_machine.remove_multiple_states(WARPING_STATES)
