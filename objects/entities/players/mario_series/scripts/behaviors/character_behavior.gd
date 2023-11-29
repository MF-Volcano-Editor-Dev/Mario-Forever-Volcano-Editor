class_name CharacterBehavior2D extends Component

## Class used to provide basic behaviors for [CharacterEntity]
##
## To override basic behaviors, just extend this class with a new script and override functions in the script [br]
## [b]Note:[/b] This will override the gravity and the max falling velocity.x of the character, see [CharacterEntity2D] [br]

const _HIGH_PRIORITY_ANIMATIONS: Array[StringName] = [&"appear", &"attack"]

const STATE_IS_CLIMBING := &"is_climbing" ## Identifierized access to the state "is_climbing"
const STATE_IS_SWIMMING := &"is_swimming" ## Identifierized access to the state "is_swimming"
const STATE_IS_SWIMMING_OUT := &"is_swimming_out" ## Identifierized access to the state "is_swimming_out"
const STATE_IS_JUMPED := &"is_jumped" ## Identifierized access to the state "is_jumped"

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
@export_group("States")
## Allows the physics movement and collision if [code]true[/code]
@export var allow_physics: bool = true
## Allows walking if [code]true[/code]
@export var allow_walking: bool = true
## Allows jumping if [code]true[/code]
@export var allow_jumping: bool = true
## Allows swimming if [code]true[/code]
@export var allow_swimming: bool = true
## Allows crouching if [code]true[/code]
@export var allow_crouching: bool = true
## Allows climbing if [code]true[/code]
@export var allow_climbing: bool = true
@export_group("Physics")
@export_subgroup("Gravity")
## Overrides the character's [member EntityBody2D.gravity]
@export_range(-1, 1, 0.001, "or_greater", "hide_slider", "suffix:x²") var gravity_scale: float = 1
## Overrides the character's [member EntityBody2D.max_falling_speed]
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var max_falling_speed: float = 500
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

@onready var power := get_parent() as CharacterPower2D ## The power that the behavior is serving for

#region == Keys pressed ==
var _on_jump: bool
var _on_jump_held: bool
var _on_running: bool
var _on_climbing: bool
#endregion

#region == Transform ==
var _pos_delta: Vector2
#endregion


## Virtual method called when the power is one switched to
func _behavior_ready() -> void:
	pass


## Virtual method called when the power is one switched from
func _behavior_disready() -> void:
	pass


func _ready() -> void:
	# Await for the readiness of the power
	# Since this is the child node of the power and the onready
	# nodes of the power should be got after all the children done _ready()
	if !power.is_node_ready():
		await power.ready
	
	# Signal connections
	power.animation.animation_finished.connect(_on_animation_finished)


func _process(delta: float) -> void:
	if disabled:
		return
	
	var pl := get_root() as CharacterEntity2D
	if !pl:
		return
	
	_controls(pl) # Control process
	
	if !ObjectState.is_state(pl, STATE_IS_CLIMBING):
		_walk(pl)
		_jump(pl, delta)
		_swim(pl, delta)
	else:
		_climb(pl)
	
	_animation(pl, delta)


func _physics_process(delta: float) -> void:
	if disabled:
		return
	
	var pl := get_root() as CharacterEntity2D
	if !pl:
		return
	
	# Overrides physics
	pl.gravity_scale = gravity_scale
	pl.max_falling_speed = max_falling_speed
	
	# Physics
	_pos_delta = pl.global_position
	_physics(pl, delta)
	_pos_delta = pl.global_position - _pos_delta
	# Fixes on wall stopping
	if _pos_delta.is_zero_approx():
		pl.velocity.x = 0
	
	# Overlapping
	var bdva := pl.body.get_overlapping_areas()
	var hdva := pl.head.get_overlapping_areas()
	_body_overlapping_process(pl, bdva) # Body overlapping
	_head_overlapping_process(pl, hdva) # Head overlapping


#region == Controls ==
func _controls(player: CharacterEntity2D) -> void:
	player.set_key_input_directions(key_left, key_right, key_up, key_down)
	
	var id: StringName = str(player.id)
	var controllable: bool = ObjectState.is_state(player, CharacterEntity2D.STATE_UNCONTROLLABLE)
	_on_jump = Input.is_action_just_pressed(key_jump + id) if controllable else false
	_on_jump_held = Input.is_action_pressed(key_jump + id) if controllable else false
	_on_running = Input.is_action_pressed(key_run + id) if controllable else false
	_on_climbing = Input.is_action_just_pressed(key_climb + id) if controllable else false
#endregion


#region == Movement ==
# Physics
func _physics(player: CharacterEntity2D, delta: float) -> void:
	if !allow_physics: # Process these codes if allows physics
		return
	# Climbing
	if ObjectState.is_state(player, STATE_IS_CLIMBING): 
		var kc := player.move_and_collide(player.global_velocity * delta)
		if kc:
			player.global_velocity = player.global_velocity.slide(kc.get_normal())
	# Non-climbing
	else:
		player.move_and_slide()
		player.correct_onto_floor()
		player.correct_on_wall_corner()

# Walking process
func _walk(player: CharacterEntity2D) -> void:
	if !allow_walking:
		return
	
	var dec := get_deceleration(player)
	if !is_allowed_to_walk(player):
		player.decelerate_walking(dec)
		return
	
	var left_right := player.get_key_input_directions().x
	player.max_speed = (max_running_speed if _on_running && !ObjectState.is_state(player, STATE_IS_SWIMMING) else max_walking_speed) * (1.0 if !is_crouching(player) else 0.25)
	
	# Initial velocity.x
	if left_right && is_zero_approx(player.velocity.x):
		player.direction = left_right
		player.velocity.x = initial_walking_speed * player.direction
	# Acceleration
	if left_right * player.direction > 0:
		# Here do NOT use accelerate_to_max_speed(), because in some cases the method would bring wrong physics
		player.accelerate_local_x(acceleration, player.max_speed * player.max_speed_scale * player.direction)
	# Turning back
	elif left_right * player.direction < 0:
		player.decelerate_walking(turning_aceleration)
		if is_zero_approx(player.velocity.x):
			player.direction *= -1
			# player.velocity.x = 6.25 * player.direction

func _jump(player: CharacterEntity2D, delta: float) -> void:
	if ObjectState.is_state(player, STATE_IS_SWIMMING) || !allow_jumping:
		return
	
	if is_jumpable(player):
		Sound.play_sound_2d(player, sound_jump)
		player.jump(initial_jumping_speed)
		make_jumped(player)
	
	if player.is_leaving_ground() && _on_jump_held:
		player.jump((jumping_acceleration_dynamic if absf(player.velocity.x) > 50 else jumping_acceleration_static) * delta, true)

func _swim(player: CharacterEntity2D, delta: float) -> void:
	if !ObjectState.is_state(player, STATE_IS_SWIMMING) || !allow_swimming:
		return
	
	if is_swimmable(player):
		Sound.play_sound_2d(player, sound_swim)
		if ObjectState.is_state(player, STATE_IS_SWIMMING_OUT): # Juming out
			player.jump(swimming_jumping_speed)
		else: # Swim
			player.jump(swimming_speed)
		
		var anim := power.animation
		if anim.current_animation == &"swim":
			anim.seek(0, true)
	
	var max_peak_speed := -absf(swimming_peak_speed)
	if !ObjectState.is_state(player, STATE_IS_SWIMMING_OUT) && player.velocity.y < max_peak_speed:
		player.velocity.y = lerpf(player.velocity.y, max_peak_speed, 8 * delta)

func _climb(player: CharacterEntity2D) -> void:
	if !allow_climbing:
		return
	
	player.velocity = Vector2(player.get_key_input_directions()).normalized() * climbing_speed
#endregion


#region == Physics collision ==
func _body_overlapping_process(player: CharacterEntity2D, overlapping_areas: Array[Area2D]) -> void:
	var body_area_count: PackedInt32Array = [0, 0] # Counts for areas
	
	# Detect overlapped areas by body detector
	for i: Area2D in overlapping_areas:
		# AreaFluid2D
		if i is AreaFluid2D: 
			body_area_count[0] += 1
			# Activate swimming
			if i.character_swimmable:
				ObjectState.set_state(player, STATE_IS_SWIMMING, true)
		
		# Climable Area
		if is_climbable(player, i):
			body_area_count[1] += 1
			ObjectState.set_state(player, STATE_IS_CLIMBING, true)
	
	# Restore data out of the fluid
	if body_area_count[0] <= 0:
		ObjectState.set_state(player, STATE_IS_SWIMMING, false) # Quits swimming
	# Restore data out of climable area
	if body_area_count[1] <= 0:
		ObjectState.set_state(player, STATE_IS_CLIMBING, false) # Quits climbing

func _head_overlapping_process(player: CharacterEntity2D, overlapping_areas: Array[Area2D]) -> void:
	var head_area_count: PackedInt32Array = [0]
	
	# Detect overlapped areas by head detector
	for i: Area2D in overlapping_areas:
		# AreaFluid2D
		if i is AreaFluid2D:
			head_area_count[0] += 1
			if i.character_swimmable:
				ObjectState.set_state(player, STATE_IS_SWIMMING_OUT, false)
	
	if head_area_count[0] <= 0:
		ObjectState.set_state(player, STATE_IS_SWIMMING_OUT, true)
#endregion


#region == Animations ==
func _animation(player: CharacterEntity2D, delta: float) -> void:
	var anim := power.animation
	anim.speed_scale = 1 # Reset animation velocity.x scale
	if power.sprite: # Set sprite flip (scale.x)
		power.sprite.scale.x = player.direction
	
	# Prevent animation player from playing high-priority animations
	if anim.current_animation in _HIGH_PRIORITY_ANIMATIONS:
		return
	
	if ObjectState.is_state(player, STATE_IS_CLIMBING):
		anim.play(&"climbing")
	elif player.is_on_floor():
		if is_crouching(player):
			anim.play(&"crouch")
		elif is_zero_approx(player.velocity.x):
			anim.play(&"idle")
		else:
			anim.play(&"walk")
			anim.speed_scale = clampf(absf(player.velocity.x) * delta * 0.67, 0, 5)
	elif ObjectState.is_state(player, STATE_IS_SWIMMING):
		anim.play(&"swim")
	elif player.is_leaving_ground():
		anim.play(&"jump")
	elif player.is_falling():
		anim.play(&"fall")

func _on_animation_finished(anim_name: StringName) -> void:
	if disabled:
		return
	
	var anim := power.animation as AnimationPlayer
	
	# Restore swimming animation
	match anim_name:
		&"swim":
			anim.advance(-0.2)
		&"attack":
			anim.play(&"idle")
#endregion


#region == Status setters ==
## After calling [method EntityBody2D.jump], please call this method to make sure the character won't 
## get continuous jumps with jumping key held
func make_jumped(player: CharacterEntity2D) -> void:
	ObjectState.set_state(player, STATE_IS_JUMPED, true)
#endregion


#region == Status getters ==
## Returns [code]true[/code] if the [param character] is crouching
func is_crouching(player: CharacterEntity2D) -> bool:
	var small_crouchable := bool(ProjectSettings.get_setting("game/control/player/crouchable_in_small_suit", false))
	return player.get_key_input_directions().y > 0 && player.is_on_floor() && (!power.is_small || (power.is_small && small_crouchable))

## Returns [code]true[/code] if the [param character] is walkable
func is_crouching_walkable(player: CharacterEntity2D) -> bool:
	var walkable_when_crouching := bool(ProjectSettings.get_setting("game/control/player/walkable_when_crouching", false))
	return walkable_when_crouching && is_crouching(player)

## Returns [code]true[/code] if the [param character] is allowed to walk
func is_allowed_to_walk(player: CharacterEntity2D) -> bool:
	var crouching := is_crouching(player)
	return player.get_key_input_directions().x && (!crouching || (crouching && is_crouching_walkable(player)))

## Returns [code]true[/code] if the [param character] is jumpable
func is_jumpable(player: CharacterEntity2D) -> bool:
	var on_floor := player.is_on_floor()
	var on_falling := player.is_falling()
	var on_crouching := is_crouching(player)
	var jumpable_when_crouching := bool(ProjectSettings.get_setting("game/control/player/jumpable_when_crouching", false))
	
	if !_on_jump_held && (on_floor || on_falling):
		ObjectState.set_state(player, STATE_IS_JUMPED, false)
	
	return !ObjectState.is_state(player, STATE_IS_SWIMMING) && !ObjectState.is_state(player, STATE_IS_JUMPED) && _on_jump_held && on_floor && (!on_crouching || (on_crouching && jumpable_when_crouching))

## Returns [code]true[/code] if the [param character] is swimmable
func is_swimmable(player: CharacterEntity2D) -> bool:
	return _on_jump && !is_crouching(player) && ObjectState.is_state(player, STATE_IS_SWIMMING)

## Returns [code]true[/code] if the [param character] is climbable in the [param area]
func is_climbable(player: CharacterEntity2D, area: Area2D) -> bool:
	return _on_climbing && area.is_in_group(&"@climbable@") && !ObjectState.is_state(player, STATE_IS_CLIMBING)


## Returns deceleration of the behavior
func get_deceleration(player: CharacterEntity2D) -> float:
	var crouching := is_crouching(player)
	return deceleration_crouching_moving if crouching && player.get_key_input_directions().x != 0 else deceleration_crouching if crouching else deceleration
#endregion
