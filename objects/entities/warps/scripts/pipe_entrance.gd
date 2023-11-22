extends Area2D

const WARPING_META_NAME: StringName = &"warp_dir"
const WARPING_STATES: Array[StringName] = [&"warping", &"no_physics", &"control_ignored", &"no_hurt", &"no_death"]

@export_category("Pipe Entrance")
@export_enum("Up: -1", "Down: 1", "Left: -2", "Right: 2") var entrance_direction: int = 1
@export_enum("Default", "Finish", "To Scene") var exit_mode: int
@export var exit: Node2D
@export_range(0, 45, 0.001, "degrees") var entrance_direction_detection_angle_offset: float = 15
@export_group("Special Exits")
@export var exit_to_scene: PackedScene
@export_group("Sounds", "sound_")
@export var sound_entering: AudioStream = preload("res://assets/sounds/power_down.wav")

var _players: Array[EntityPlayer2D]

@onready var pos_right: Marker2D = $PosRight
@onready var pos_left: Marker2D = $PosLeft


func _ready() -> void:
	if !ProjectSettings.get_setting("debug/shapes/collision/draw_2d_outlines"):
		visible = false
	
	area_entered.connect(_on_player_entered)
	area_exited.connect(_on_player_exited)


func _process(_delta: float) -> void:
	for i: EntityPlayer2D in _players:
		# Check and remove invalid players
		if !is_instance_valid(i) || i.state_machine.is_state(&"warping"):
			_players.erase(i)
			continue
		
		# Key detection
		var twbl: bool = false
		var dir:= i.get_key_direction()
		match entrance_direction:
			1 when dir.y > 0:
				twbl = true
			-1 when dir.y < 0:
				twbl = true
			2 when dir.x > 0:
				twbl = true
			-2 when dir.x < 0:
				twbl = true
		if !twbl:
			return
		
		# Set player's warping direction on entering the pipe and set relative states
		i.set_meta(WARPING_META_NAME, entrance_direction)
		i.state_machine.set_multiple_states(WARPING_STATES)
		
		# Reset player's physics data
		i.speed = 0
		i.velocity = Vector2.ZERO
		
		var tw := i.create_tween() # Create tween
		
		# Facing direction adn target global position
		var facing := Vector2.DOWN.rotated(global_rotation)
		var tar := (global_position if absi(entrance_direction) != 2 else pos_right.global_position if entrance_direction > 0 else pos_left.global_position) + facing * 60
		
		# Entering
		var dnofs := Vector2.ZERO
		# Position fix on vertical entering
		if absi(entrance_direction) == 1: 
			dnofs = (i.global_position - global_position).project(facing)
			tw.tween_property(i, ^"global_position", global_position + dnofs, 0.1).set_trans(Tween.TRANS_SINE)
		# Position fix on horizontal entering
		elif absi(entrance_direction) == 2:
			tw.tween_property(i, ^"global_position", pos_right.global_position if entrance_direction > 0 else pos_left.global_position, 0.1).set_trans(Tween.TRANS_SINE)
		
		# Applys the movement of entering the pipe
		tw.tween_callback(Sound.play_sound_2d.bind(self, sound_entering))
		tw.tween_property(i, ^"global_position", tar, 1)
		# Calls the method to pass the player to the exit if the movement is over
		tw.finished.connect(_pass_to_exit.bind(i))


func _pass_to_exit(player: EntityPlayer2D) -> void:
	match exit_mode:
		0 when exit is Classes.PipeExit:
			exit.player_exit(player)
		0 when !exit is Classes.PipeExit:
			printerr("The exit is invalid!")
		1:
			EventsManager.level_finish()
		2 when exit_to_scene:
			Scenes.jump_to_scene_packed(exit_to_scene)
		2 when !exit_to_scene:
			printerr("No exit_to_scene set, or the scene you set is invalid!")


func _on_player_entered(area: Area2D) -> void:
	var pl := area.get_parent() as EntityPlayer2D
	if !pl:
		return
	
	if !pl in _players && !pl.state_machine.is_state(&"warping"):
		_players.append(pl)


func _on_player_exited(area: Area2D) -> void:
	var pl := area.get_parent() as EntityPlayer2D
	if !pl:
		return
	
	if pl in _players && !pl.state_machine.is_state(&"warping"):
		_players.erase(pl)
