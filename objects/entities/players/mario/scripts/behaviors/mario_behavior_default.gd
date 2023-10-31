extends Component

@export_category("Mario Behaviors")
## Override the properties for [Mario2D][br]
## [b]Note:[/b] The properties should be written in NodePath-style with [String] type
@export var override_player_properties: Dictionary = {}
## Names of key inputs [br]
## See project settings -> input for more details [br]
## [b]Note:[/b] Acutally, the key input is <key_name> + <[member EntityPlayer2D.id]>.
## For exaple: the left key, if the player's id is 0, is actually [code]&"left0"[/code]
@export_group("Key Inputs")
## Left key
@export var key_left: StringName = &"left"
## Right key
@export var key_right: StringName = &"right"
## Up key
@export var key_up: StringName = &"up"
## Down key
@export var key_down: StringName = &"down"
## Key of controlling jumping
@export var key_jump: StringName = &"jump"
## Key of controlling running
@export var key_run: StringName = &"run"
## Key of controlling climbing
@export var key_climb: StringName = &"up"
@export_group("Movement")
@export_subgroup("Walking")
## Initial walking speed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var initial_walking_speed: float = 50
## Acceleration
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var acceleration: float = 312.5
## Deceleration
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var deceleration: float = 312.5
## Deceleration when the speed is greater than [member max_walking_speed](not running) or [member max_running_speed](running)
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var deceleration_overspeed: float = 312.5
## Deceleration when crouching
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var deceleration_crouching: float = 312.5
## Deceleration when crouching with arrows pressed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var deceleration_crouching_moving: float = 125
## Turning acceleration/deceleration
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var turning_aceleration: float = 1250
## Minimum of the walking speed, better to keep it 0 [br]
## [b]Note:[/b] A value greater than 0 will lead to non-stopping of the player after he finishes deceleration
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var min_speed: float
## Maximum of the walking speed in non-running state
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var max_walking_speed: float = 175
## Maximum of the walking speed in running state
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var max_running_speed: float = 350
@export_subgroup("Jumping")
## Initial jumping speed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var initial_jumping_speed: float = 700
## Jumping acceleration when the jumping key is held and the player IS NOT walking
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var jumping_acceleration_static: float = 1000
## Jumping acceleration when the jumping key is held and the player IS walking
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s²") var jumping_acceleration_dynamic: float = 1250
@export_subgroup("Swimming")
## Swimming speed under the surface of water
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var swimming_speed: float = 150
## Swimming speed near the surface of water
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var swimming_jumping_speed: float = 450
## Peak speed of swimming speed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var swimming_peak_speed: float = 150
@export_subgroup("Climbing")
## Moving speed when climbing
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var climbing_speed: float = 150
@export_group("Behavior Sounds", "sound_")
## Jumping sound
@export var sound_jump: AudioStream = preload("res://assets/sounds/jump.wav")
## Swimming sound
@export var sound_swim: AudioStream = preload("res://assets/sounds/swim.wav")

## Fast access to [member Component.root] casted to [Mario2D]
var mario: Mario2D

var _start_animations: bool # Used to defer the animation process for 1 frame at the beginning of the game
var _pos_delta: Vector2 # Used to prevent mario colliding with a wall from playing walking animation when pressing the key towards the wall

# These are controlled keys
var _left_right: int # Key direction horizontal
var _up_down: int # Key direction vertical
var _jumped: bool # True only if the jumping key is pressed and not being held
var _jumping: bool # True when holding jumping key
var _jumped_already: bool # True when not close jumping and holding jumping key, prevent from continuous jump by holding the key
var _running: bool # True if the running key is held
var _climbed: bool # True only if the climbing key (defaultly up) is pressed and not being held

# These are written as variables because they are set each frame, most of which are from project settings -> Game -> Control -> Player
var _jumpable_when_crouching: bool
var _walkable_when_crouching: bool
var _crouchable_in_small_suit: bool

@onready var suit: MarioSuit2D = $".."
@onready var sprite: Sprite2D = $"../Sprite2D"
@onready var animation: AnimationPlayer = $"../AnimationPlayer"
@onready var shapes_controller: AnimationPlayer = $"../AnimationShape"
@onready var sound: Sound2D = $"../Sound2D"
@onready var aqua_root: Node = $"../AquaUpdater/AquaRoot"
@onready var aqua_behavior: Node = $"../AquaUpdater/AquaBehavior"


#region Main methods
func _ready() -> void:
	super()
	
	# Set root
	mario = (root as MarioSuit2D).get_player()
	
	# Animations
	animation.animation_finished.connect(_on_animation_swim_reset)
	shapes_controller.play.call_deferred(&"RESET")
	
	# Detections
	# Await for readiness of mario for safety of initialization
	if !mario.is_node_ready():
		await mario.ready
	mario.suit_changed.connect(_on_mario_suit_changed)
	mario.body.area_entered.connect(_on_body_entered_area)
	mario.body.area_exited.connect(_on_body_exited_area)
	mario.head.area_entered.connect(_on_head_entered_area)
	mario.head.area_exited.connect(_on_head_exited_area)


func _process(delta: float) -> void:
	# States & Controls
	_general_states_process()
	_control_states_process()
	_action_states_process()
	
	# Movement
	if mario.state_machine.is_state(&"climbing"):
		_movement_climb_process()
	else:
		_movement_crouching_process()
		_movement_x_process(delta)
		_movement_y_process(delta)
	
	# Animations
	if _start_animations:
		_animation_process(delta)
	_start_animations = true


func _physics_process(delta: float) -> void:
	_pos_delta = mario.global_position
	
	if mario.state_machine.is_state(&"climbing"):
		_movement_climbing_physics_process(delta)
	else:
		_movement_normal_physics_process(delta)
	
	_pos_delta = mario.global_position - _pos_delta
#endregion


#region States Controls
func _general_states_process() -> void:
	# States from global settings
	_jumpable_when_crouching = ProjectSettings.get_setting("game/control/player/jumpable_when_crouching", false)
	_walkable_when_crouching = ProjectSettings.get_setting("game/control/player/walkable_when_crouching", false)
	_crouchable_in_small_suit = ProjectSettings.get_setting("game/control/player/crouchable_in_small_suit", false)


#region Controls
func _control_states_process() -> void:
	# Basic controls
	_left_right = int(Input.get_axis(_get_key_input(key_left), _get_key_input(key_right)))
	_up_down = int(Input.get_axis(_get_key_input(key_up), _get_key_input(key_down)))
	_jumped = Input.is_action_just_pressed(_get_key_input(key_jump))
	_jumping = Input.is_action_pressed(_get_key_input(key_jump))
	_running = Input.is_action_pressed(_get_key_input(key_run))
	_climbed = Input.is_action_just_pressed(_get_key_input(key_climb))


func _get_key_input(key_name: StringName) -> StringName:
	return key_name + StringName(str(mario.id))
#endregion


#region Action
func _action_states_process() -> void:
	# Climbing
	if _climbed && !mario.state_machine.is_state(&"climbing") && mario.state_machine.is_state(&"is_climbable"):
		mario.state_machine.set_state(&"climbing")
		_jumped_already = false
#endregion
#endregion


#region Movements
func _accelerate(to: float, acce_with_delta: float) -> void:
	mario.velocity.x = move_toward(mario.velocity.x, to * mario.direction, acce_with_delta)


func _movement_crouching_process() -> void:
	if mario.state_machine.is_state(&"no_crouching"):
		return
	
	var sm: bool = "small" in suit.suit_features # Small
	var crbl: bool = (_crouchable_in_small_suit && sm) || !sm # Crouchable
	var ofd: bool = _up_down > 0 && mario.is_on_floor() # On floor down
	
	if ofd && crbl:
		if !mario.state_machine.is_state(&"crouching"):
			mario.state_machine.set_state(&"crouching")
			shapes_controller.play.call_deferred(&"crouch")
	elif mario.state_machine.is_state(&"crouching"):
		mario.state_machine.remove_state(&"crouching")
		shapes_controller.play.call_deferred(&"RESET")


func _movement_x_process(delta: float) -> void:
	if mario.state_machine.is_state(&"no_walking"):
		return
	
	# Deceleration
	var isdc: int = _is_decelerating() # Is deceleration
	var dc: float = deceleration if isdc == 1 else \
		deceleration_crouching if isdc == 2 else \
		deceleration_crouching_moving # Deceleration
	if isdc:
		_accelerate(min_speed, dc * delta)
		return
	# Initial speed
	if _left_right != 0 && mario.velocity.x == 0:
		mario.direction = _left_right
		mario.velocity.x = initial_walking_speed * mario.direction
	# Acceleration
	elif _left_right * signf(mario.velocity.x) > 0:
		var isrn: bool = _is_running() # Is running
		var cw: bool = _walkable_when_crouching && mario.state_machine.is_state(&"crouching") # Crouchwalk
		var wf: float = 0.1 if cw else 1.0 # Walking factor
		var ms: float = (max_running_speed if isrn else max_walking_speed) * wf # Max speed
		
		# Set state for users to detect
		if isrn:
			mario.state_machine.set_state(&"running")
		else:
			mario.state_machine.remove_state(&"running")
		
		# Execute acceleration
		if abs(mario.velocity.x) < ms:
			_accelerate(ms, acceleration * delta)
		# Deceleration if the velocity is greater than max speed
		elif abs(mario.velocity.x) > ms:
			_accelerate(ms, deceleration_overspeed * delta)
	# Turning back
	elif _left_right * signf(mario.velocity.x) < 0:
		_accelerate(0, turning_aceleration * delta)
		mario.state_machine.set_state(&"turning")
		
		if is_zero_approx(mario.velocity.x):
			mario.direction *= -1
			mario.state_machine.remove_state(&"turning")


func _movement_y_process(delta: float) -> void:
	if mario.state_machine.is_state(&"no_jumping"):
		return
	
	var uw: bool = mario.state_machine.is_state(&"underwater") # Underwater 
	var uwjo: bool = mario.state_machine.is_state(&"underwater_jumpout") # Underwater jump-out
	var cr: bool = mario.state_machine.is_state(&"crouching") # Crouching
	var jpb: bool = (_jumpable_when_crouching && cr) || !cr # Jumpable
	
	_reset_jumping_already()
	# Underwater (Swimming)
	if uw:
		if _jumped:
			sound.play(sound_swim)
			
			# Jumping out of water
			if uwjo:
				mario.jump(swimming_jumping_speed)
			# Swimming still
			else:
				mario.jump(swimming_speed)
			
			_jumped_already = true
		
		# Underwater peak swimming speed
		var swp: float = -abs(swimming_peak_speed)
		if !uwjo && mario.velocity.y < swp:
			mario.velocity.y = lerpf(mario.velocity.y, swp, 0.1)
	# Non-underwater (Jumping)
	else:
		if _is_jumpable() && jpb && mario.is_on_floor():
			sound.play(sound_jump)
			mario.jump(initial_jumping_speed)
			_jumped_already = true
		
		# Jumping acceleration
		if _jumping && mario.velocity.y < 0 && !mario.is_on_floor():
			var jac: float = jumping_acceleration_dynamic if absf(mario.velocity.x) > 31.25 else jumping_acceleration_static
			mario.jump(jac * delta, true)


func _movement_normal_physics_process(_delta: float) -> void:
	mario.move_and_slide()
	mario.correct_onto_floor()
	mario.correct_on_wall_corner()


func _movement_climb_process() -> void:
	if mario.state_machine.is_state(&"no_climbing"):
		mario.state_machine.remove_state(&"climbing")
		return
	
	# Direction correcting
	if _left_right != 0:
		mario.direction = _left_right
	
	# Velocity
	mario.velocity = (Vector2(_left_right, _up_down).normalized() if _left_right || _up_down else Vector2.ZERO) * climbing_speed
	
	# Jumping from climbing
	if _is_jumpable() && _up_down >= 0:
		_jumped_already = true
		sound.play(sound_jump)
		mario.jump(initial_jumping_speed)
		mario.state_machine.remove_state(&"climbing")


func _movement_climbing_physics_process(delta: float) -> void:
	var c := mario.move_and_collide(mario.global_velocity * delta)
	if c: 
		mario.global_velocity = mario.global_velocity.slide(c.get_normal())
		
		# Stop the character from climbing when touching the ground by pressing down key
		if _up_down > 0:
			var rg := mario.test_move(mario.global_transform, -mario.up_direction)
			if rg && mario.state_machine.is_state(&"climbing"):
				mario.state_machine.remove_state(&"climbing")


#region Test for Movement
func _is_decelerating() -> int:
	var dc: bool = _left_right == 0 # Decelerating
	var cronly: bool = mario.state_machine.is_state(&"crouching") && !_walkable_when_crouching # Crouching only
	
	if dc:
		return 1
	elif cronly:
		if !_left_right:
			return 2
		else:
			return 3
	return 0


func _is_running() -> bool:
	return _running


func _is_jumpable() -> bool:
	return _jumping && !_jumped_already


func _reset_jumping_already() -> void:
	if !_jumping && (mario.velocity.y > 0 || mario.is_on_floor()):
		_jumped_already = false
#endregion
#endregion


#region Animations
func _animation_process(delta: float) -> void:
	animation.speed_scale = 1
	sprite.scale.x = mario.direction
	
	if animation.current_animation in [&"appear", &"attack"]:
		return
	
	# Climbing
	if mario.state_machine.is_state(&"climbing"):
		animation.play(&"climb")
		animation.speed_scale = 0.0 if mario.velocity.is_zero_approx() else 1.0
	else:
		sprite.flip_h = false
		
		if mario.is_on_floor():
			# Crouching
			if mario.state_machine.is_state(&"crouching"):
				animation.play(&"crouch")
			# Idle
			elif is_zero_approx(snappedf(_pos_delta.length_squared(), 0.01)):
				animation.play(&"RESET")
			# Walking
			else:
				animation.play(&"walk")
				animation.speed_scale = clampf(absf(mario.velocity.x) * delta * 0.67, 0, 5)
		# Swimming
		elif mario.state_machine.is_state(&"underwater"):
			if _jumped: # Reset swimming animation when the jumping key is pressed
				animation.stop()
			animation.play(&"swim")
		# Jumping
		elif mario.velocity.y < 0:
			animation.play(&"jump")
		# Falling
		else:
			animation.play(&"fall")


func _on_animation_swim_reset(anim_name: StringName) -> void:
	match anim_name:
		&"swim":
			animation.advance(-0.2)
#endregion


#region Suit changed
func _on_mario_suit_changed(to: StringName) -> void:
	if to != suit.suit_id:
		return
	
	# Override properties
	for i in override_player_properties:
		mario.set_indexed(i, override_player_properties[i])
	
	# Make the following properties keep the same
	# performances even if the current suit is changed
	# If no such codes, for example, when the character is
	# underwater, the property in underwater will be incorrect
	# when he changes to other suits.
	if mario.state_machine.is_state(&"underwater"):
		aqua_root.update_from_component()
		aqua_behavior.update_from_component()
	else:
		aqua_root.update_from_extracted_value()
		aqua_behavior.update_from_extracted_value()
#endregion


#region Detections
#region Body's
func _on_body_entered_area(area: Area2D) -> void:
	if !suit.is_current():
		return
	
	# AreaClimbable2D
	if area is AreaClimbable2D:
		# Use a state to store the climbable state, and when
		# the climbing key is pressed, the player will
		# climb on the climable object
		if !mario.state_machine.is_state(&"is_climbable"):
			mario.state_machine.set_state(&"is_climbable")
	# AreaFluid2D
	elif area is AreaFluid2D:
		if area.fluid_id == &"water" && !mario.state_machine.is_state(&"underwater"):
			mario.state_machine.set_state(&"underwater")
			aqua_root.update_from_component()
			aqua_behavior.update_from_component()


func _on_body_exited_area(area: Area2D) -> void:
	if !suit.is_current():
		return
	
	# AreaClimbable2D
	if area is AreaClimbable2D:
		if mario.state_machine.is_state(&"is_climbable"):
			mario.state_machine.remove_state(&"is_climbable")
		if mario.state_machine.is_state(&"climbing"):
			mario.state_machine.remove_state(&"climbing")
	# AreaFluid2D
	elif area is AreaFluid2D:
		if mario.state_machine.is_state(&"underwater"):
			mario.state_machine.remove_state(&"underwater")
			aqua_root.update_from_extracted_value()
			aqua_behavior.update_from_extracted_value()
#endregion


#region Head's
func _on_head_entered_area(area: Area2D) -> void:
	if !suit.is_current():
		return
	
	# AreaFluid2D
	if area is AreaFluid2D:
		if area.fluid_id == &"water" && mario.state_machine.is_state(&"underwater_jumpout"):
			mario.state_machine.remove_state(&"underwater_jumpout")


func _on_head_exited_area(area: Area2D) -> void:
	if !suit.is_current():
		return
	
	# AreaFluid2D
	if area is AreaFluid2D:
		if !mario.state_machine.is_state(&"underwater_jumpout"):
			mario.state_machine.set_state(&"underwater_jumpout")
#endregion
#endregion


#region Setters & Getters
func get_left_right() -> int:
	return _left_right


func get_up_down() -> int:
	return _up_down
#endregion
