class_name CharacterBehavior2D extends Component

## Class used to provide basic behaviors for [CharacterEntity]

const IS_SMALL := &"is_small"
const ALLOWS_WALKING := &"allows_walking"
const ALLOWS_JUMPING := &"allows_jumping"
const ALLOWS_SWIMMING := &"allows_swimming"
const ALLOWS_CROUCHING := &"allows_crouching"
const ALLOWS_CLIMBING := &"allows_climbing"

const _HIGH_PRIORITY_ANIMATIONS: Array[StringName] = [&"appear", &"attack"]

const _IS_CLIMBING := &"on_climbing"

@export_category("Character Behaviors")
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
@export_group("Physics")
@export_subgroup("Walking")
## Initial walking speed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_walking_speed: float = 50
## Acceleration
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var acceleration: float = 312.5
## Deceleration
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var deceleration: float = 312.5
## Deceleration when crouching
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var deceleration_crouching: float = 312.5
## Deceleration when crouching with arrows pressed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var deceleration_crouching_moving: float = 125
## Turning acceleration/deceleration
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var turning_aceleration: float = 1250
## Minimum of the walking speed, better to keep it 0 [br]
## [b]Note:[/b] A value greater than 0 will lead to non-stopping of the player after he finishes deceleration
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var min_speed: float
## Maximum of the walking speed in non-running state
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_walking_speed: float = 175
## Maximum of the walking speed in running state
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var max_running_speed: float = 350
@export_subgroup("Jumping")
## Initial jumping speed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_jumping_speed: float = 700
## Jumping acceleration when the jumping key is held and the player IS NOT walking
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var jumping_acceleration_static: float = 1000
## Jumping acceleration when the jumping key is held and the player IS walking
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var jumping_acceleration_dynamic: float = 1250
@export_subgroup("Underwater")
## Swimming speed under the surface of water
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var swimming_speed: float = 150
## Swimming speed near the surface of water
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var swimming_jumping_speed: float = 450
## Peak speed of swimming speed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var swimming_peak_speed: float = 150
@export_subgroup("Climbing")
## Moving speed when climbing
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var climbing_speed: float = 150
@export_group("Behavior Sounds", "sound_")
## Jumping sound
@export var sound_jump: AudioStream = preload("res://assets/sounds/jump.wav")
## Swimming sound
@export var sound_swim: AudioStream = preload("res://assets/sounds/swim.wav")

@onready var power := get_parent() as CharacterPower2D

#region == Keys pressed ==
var _on_jump: bool
var _on_jump_held: bool
var _on_running: bool
var _on_climbing: bool
#endregion

#region == Status ==
var _is_jumped: bool
var _is_climbing: bool
var _on_swimming: bool
var _on_swimming_jumping: bool = true
#endregion

#region == Transform ==
var _pos_delta: Vector2
#endregion


## Virtual method called when the power is one switched to
func _behavior_ready() -> void:
	_is_climbing = root.get_meta(_IS_CLIMBING, false) # Loads climbing


## Virtual method called when the power is one switched from
func _behavior_disready() -> void:
	root.set_meta(_IS_CLIMBING, _is_climbing) # Saves climbing


func _ready() -> void:
	super()
	
	# Await for the readiness of the power
	# Since this is the child node of the power and the onready
	# nodes of the power should be got after all the children done _ready()
	if !power.is_node_ready():
		await power.ready
	
	power.animation.animation_finished.connect(_on_animation_finished)


func _process(delta: float) -> void:
	var pl := root as CharacterEntity2D
	if !pl:
		return
	
	_controls(pl) # Control process
	
	if !_is_climbing:
		_walk(pl)
		_jump(pl, delta)
		_swim(pl, delta)
	else:
		_climb(pl, delta)
	
	_animation(pl, delta)


func _physics_process(delta: float) -> void:
	var pl := root as CharacterEntity2D
	if !pl:
		return
	
	_pos_delta = pl.global_position
	
	if !_is_climbing: # Non-climbing
		pl.move_and_slide()
		pl.correct_onto_floor()
		pl.correct_on_wall_corner()
	else: # Climbing
		var kc := pl.move_and_collide(pl.global_velocity * delta)
		if kc:
			pl.global_velocity = pl.global_velocity.slide(kc.get_normal())
	
	_pos_delta = pl.global_position - _pos_delta
	
	if _pos_delta.is_zero_approx(): # Fixes on wall stopping
		pl.speed = 0
	
	_overlapping_process(pl) # Overlapping


#region == Controls ==
func _controls(player: CharacterEntity2D) -> void:
	player.set_key_input_directions(key_left, key_right, key_up, key_down)
	
	var id: StringName = str(player.id)
	_on_jump = Input.is_action_just_pressed(key_jump + id)
	_on_jump_held = Input.is_action_pressed(key_jump + id)
	_on_running = Input.is_action_pressed(key_run + id)
	_on_climbing = Input.is_action_just_pressed(key_climb + id)
#endregion


#region == Movement ==
# Walking process
func _walk(player: CharacterEntity2D) -> void:
	if !is_walking_enabled():
		return
	
	var dec := get_deceleration(player)
	if !is_allowed_to_walk(player):
		player.decelerate_walking(dec)
		return
	
	var left_right := player.get_key_input_directions().x
	var max_speed := (max_running_speed if _on_running else max_walking_speed) * (1.0 if !is_crouching(player) else 0.25)
	
	# Initial speed
	if left_right && is_zero_approx(player.speed):
		player.direction = left_right
		player.speed = initial_walking_speed * player.direction
	# Acceleration
	if left_right * player.direction > 0:
		# Within speed range
		if absf(player.speed) < max_speed:
			player.accelerate_walking(acceleration, max_speed)
		# Oversped
		elif absf(player.speed) > max_speed:
			player.decelerate_walking(dec * 2)
	# Turning back
	elif left_right * player.direction < 0:
		player.decelerate_walking(turning_aceleration)
		if is_zero_approx(player.speed):
			player.direction *= -1
			# player.speed = 6.25 * player.direction

func _jump(player: CharacterEntity2D, delta: float) -> void:
	if _on_swimming || !is_jumping_enabled():
		return
	
	if is_jumpable(player):
		Sound.play_sound_2d(player, sound_jump)
		player.jump(initial_jumping_speed)
		make_jumped()
	
	if player.is_leaving_ground() && _on_jump_held:
		player.jump((jumping_acceleration_dynamic if absf(player.speed) > 50 else jumping_acceleration_static) * delta, true)

func _swim(player: CharacterEntity2D, delta: float) -> void:
	if !_on_swimming || !is_swimming_enabled():
		return
	
	if is_swimmable(player):
		Sound.play_sound_2d(player, sound_swim)
		if _on_swimming_jumping: # Juming out
			player.jump(swimming_jumping_speed)
		else: # Swim
			player.jump(swimming_speed)
		
		var anim := power.animation
		if anim.current_animation == &"swim":
			anim.seek(0)
	
	if player.velocity.y < -swimming_peak_speed:
		lerpf(player.velocity.y, -swimming_peak_speed, 24 * delta)

func _climb(player: CharacterEntity2D, delta: float) -> void:
	player.velocity = Vector2(player.get_key_input_directions()).normalized() * climbing_speed
#endregion


#region == Physics collision ==
func _overlapping_process(player: CharacterEntity2D) -> void:
	var body_area_count: PackedInt32Array = [0, 0] # Counts for areas
	var fluid_data_average: Dictionary = { # Fluid data
		AreaFluid2D.CHARACTER_MAX_FALLING_SPEED_FACTOR: 0.0,
		AreaFluid2D.CHARACTER_MAX_WALKING_SPEED_FACTOR: 0.0,
		AreaFluid2D.CHARACTER_MAX_RUNNING_SPEED_FACTOR: 0.0
	}
	
	# == Body ==
	# Detect overlapped areas by body detector
	for i: Area2D in player.body.get_overlapping_areas():
		# AreaFluid2D
		if i is AreaFluid2D: 
			body_area_count[0] += 1
			
			# Activate swimming
			if i.get_meta(AreaFluid2D.CHARACTER_SWIMMABLE, false):
				_on_swimming = true
			
			# Store the physics data from the fluid's metadata
			for j: StringName in fluid_data_average:
				fluid_data_average[j] += i.get_meta(j, 1.0)
		# Climable Area
		if is_climbable(i):
			body_area_count[1] += 1
			_is_climbing = true
		# Enemy Stomping
	
	
	# Sets the average of each fluid data
	for k: StringName in fluid_data_average:
		fluid_data_average[k] /= float(body_area_count[0])
	
	# Restore data out of the fluid
	if body_area_count[0] <= 0:
		# Disables swimming
		_on_swimming = false
		
		var rsd := player.get_meta(CharacterEntity2D.PHYSICS_OVERWORLD, {}) as Dictionary
		if rsd.is_empty():
			return
		
		player.max_falling_speed = rsd.max_falling_speed
		max_walking_speed = rsd.max_walking_speed
		max_running_speed = rsd.max_running_speed
		player.remove_meta(CharacterEntity2D.PHYSICS_OVERWORLD)
	# Set data in the fluid
	elif !player.has_meta(CharacterEntity2D.PHYSICS_OVERWORLD):
		player.set_meta(CharacterEntity2D.PHYSICS_OVERWORLD, {
			max_falling_speed = player.max_falling_speed,
			max_walking_speed = self.max_walking_speed,
			max_running_speed = self.max_running_speed
		})
		
		player.max_falling_speed *= fluid_data_average[AreaFluid2D.CHARACTER_MAX_FALLING_SPEED_FACTOR]
		max_walking_speed *= fluid_data_average[AreaFluid2D.CHARACTER_MAX_WALKING_SPEED_FACTOR]
		max_running_speed *= fluid_data_average[AreaFluid2D.CHARACTER_MAX_RUNNING_SPEED_FACTOR]
	
	# Restore data out of climable area
	if body_area_count[1] <= 0:
		_is_climbing = false
	
	# == Head ==
	var head_area_count: PackedInt32Array = [0]
	
	# Detect overlapped areas by head detector
	for l: Area2D in player.head.get_overlapping_areas():
		# AreaFluid2D
		if l is AreaFluid2D:
			head_area_count[0] += 1
			
			if l.get_meta(AreaFluid2D.CHARACTER_SWIMMABLE, false):
				_on_swimming_jumping = false
	
	if head_area_count[0] <= 0:
		_on_swimming_jumping = true
#endregion


#region == Animations ==
func _animation(player: CharacterEntity2D, delta: float) -> void:
	var anim := power.animation
	anim.speed_scale = 1 # Reset animation speed scale
	if power.sprite: # Set sprite flip (scale.x)
		power.sprite.scale.x = player.direction
	
	# Prevent animation player from playing high-priority animations
	if anim.current_animation in _HIGH_PRIORITY_ANIMATIONS:
		return
	
	if _is_climbing:
		anim.play(&"climbing")
	elif player.is_on_floor():
		if is_crouching(player):
			anim.play(&"crouch")
		elif is_zero_approx(player.speed):
			anim.play(&"idle")
		else:
			anim.play(&"walk")
			anim.speed_scale = clampf(absf(player.speed) * delta * 0.67, 0, 5)
	elif _on_swimming:
		anim.play(&"swim")
	elif player.is_leaving_ground():
		anim.play(&"jump")
	elif player.is_falling():
		anim.play(&"fall")

func _on_animation_finished(anim_name: StringName) -> void:
	var anim := power.animation as AnimationPlayer
	
	# Restore swimming animation
	match anim_name:
		&"swim":
			anim.advance(-0.2)
		&"attack":
			anim.play(&"idle")
#endregion


#region == Status setters ==
func make_jumped() -> void:
	_is_jumped = true
#endregion


#region == Status getters ==
func is_crouching(player: CharacterEntity2D) -> bool:
	var small := bool(get_meta(IS_SMALL, false))
	var small_crouchable := bool(ProjectSettings.get_setting("game/control/player/crouchable_in_small_suit", false))
	return player.get_key_input_directions().y > 0 && player.is_on_floor() && (!small || (small && small_crouchable))

func is_crouching_walkable(player: CharacterEntity2D) -> bool:
	var walkable_when_crouching := bool(ProjectSettings.get_setting("game/control/player/walkable_when_crouching", false))
	return walkable_when_crouching && is_crouching(player)

func is_walking_enabled() -> bool:
	return bool(get_meta(ALLOWS_WALKING, false))

func is_allowed_to_walk(player: CharacterEntity2D) -> bool:
	var crouching := is_crouching(player)
	return player.is_controllable() && player.get_key_input_directions().x && (!crouching || (crouching && is_crouching_walkable(player)))

func is_jumping_enabled() -> bool:
	return bool(get_meta(ALLOWS_JUMPING, false))

func is_jumpable(player: CharacterEntity2D) -> bool:
	var on_floor := player.is_on_floor()
	var on_falling := player.is_falling()
	var on_crouching := is_crouching(player)
	var jumpable_when_crouching := bool(ProjectSettings.get_setting("game/control/player/jumpable_when_crouching", false))
	
	if !_on_jump_held && (on_floor || on_falling):
		_is_jumped = false
	
	return !_on_swimming && _on_jump_held && !_is_jumped && on_floor && (!on_crouching || (on_crouching && jumpable_when_crouching))

func is_swimming_enabled() -> bool:
	return bool(get_meta(ALLOWS_SWIMMING, false))

func is_swimmable(player: CharacterEntity2D) -> bool:
	return _on_swimming && _on_jump && !is_crouching(player)

func is_climbable(area: Area2D) -> bool:
	return _on_climbing && !_is_climbing && area.is_in_group(&"@climbable@")


func get_deceleration(player: CharacterEntity2D) -> float:
	var crouching := is_crouching(player)
	return deceleration_crouching_moving if crouching && player.get_key_input_directions().x != 0 else deceleration_crouching if crouching else deceleration
#endregion
