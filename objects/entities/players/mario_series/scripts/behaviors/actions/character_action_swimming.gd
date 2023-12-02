extends CharacterAction2D

const ActionCrouch := preload("./character_action_crouch.gd")
const ActionClimb := preload("./character_action_climbing.gd")

const STATE_SWIMMING := &"is_swimming"
const STATE_SWIMMING_OUT := &"is_swimming_out" ## Identifierized access to the state "is_swimming_out"

@export_category("Action Swimming")
@export_group("Key")
@export var key_swim: StringName = &"jump" ## Key swim
@export_subgroup("Swimming")
## Swimming speed under the surface of water
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var swimming_speed: float = 150
## Swimming speed near the surface of water
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var swimming_jumping_speed: float = 450
## Peak speed of swimming speed
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var swimming_peak_speed: float = 150
@export_group("Sounds", "sound_")
## Swimming sound
@export var sound_swim: AudioStream = preload("res://assets/sounds/swim.wav")


func _ready() -> void:
	await Process.await_readiness(power) # Await for a safe reference
	power.animation.animation_finished.connect(_on_swim_restart_animation)


func _process(delta: float) -> void:
	if disabled:
		return
	
	_swim(delta)
	_animation()


#region == Swim ==
func _swim(delta: float) -> void:
	if !ObjectState.is_state(character, STATE_SWIMMING):
		return
	
	if is_swimmable():
		Sound.play_sound_2d(character, sound_swim)
		if ObjectState.is_state(character, STATE_SWIMMING_OUT): # Juming out
			character.jump(swimming_jumping_speed)
		else: # Swim
			character.jump(swimming_speed)
		
		if power.animation.current_animation == &"swim":
			power.animation.seek(0, true)
	
	var max_peak_speed := -absf(swimming_peak_speed)
	if !ObjectState.is_state(character, STATE_SWIMMING_OUT) && character.velocity.y < max_peak_speed:
		character.velocity.y = lerpf(character.velocity.y, max_peak_speed, 8 * delta)

func _animation() -> void:
	if behavior.is_playing_unbreakable_animation():
		return
	
	if !character.is_on_floor() && ObjectState.is_state(character, STATE_SWIMMING) && !ObjectState.is_state(character, ActionClimb.STATE_CLIMBING):
		power.animation.speed_scale = 1
		power.animation.play(&"swim")

func _on_swim_restart_animation(anim: StringName) -> void:
	if anim == &"swim":
		power.animation.advance(-0.2)
#endregion


## Returns [code]true[/code] if the [param character] is swimmable
func is_swimmable() -> bool:
	if !character.controllable:
		return false
	
	return Input.is_action_just_pressed(key_swim + str(character.id)) && !ObjectState.is_state(character, ActionCrouch.STATE_CROUCHING) && ObjectState.is_state(character, STATE_SWIMMING)
