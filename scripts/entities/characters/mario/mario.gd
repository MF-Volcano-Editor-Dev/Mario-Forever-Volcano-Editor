class_name Mario extends Character

## Character that behaves similarly to Mario
##
## [Mario] here is not a specific character, but a type of characters that behaves similar to Mario.
## You can specify a powerup that makes the character be in such suit and get powerful skills.

const _MarioDeath: Script = preload("./mario_death.gd")

## Id of current powerup.[br]
## [br]
## [b]Note:[/b] This will automatically set the powerup of the mario to one that contains the same [member current_powerup] matched.
## If a dismatched powerup id is set, some unexpected behaviors would happen, so please ensure this value valid in terms of existing powerups.
@export var current_powerup: StringName = &"small":
	set = set_powerup
## If [code]true[/code], the powerup will not play [code]&"appear"[/code] animation.[br]
## If [member current_powerup] is invalid, nothing is going to happen.
@export var no_appearing_animation_when_ready: bool = true

@onready var _death: _MarioDeath = $MarioDeath # Death effect of the character 

var _powerup: MarioPowerup # Current powerup
var _invulnerablity_counter: SceneTreeTimer # Invulerability time counter


func _ready() -> void:
	current_powerup = current_powerup # Triggers "set_powerup" to set initial powerup


#region == Setgets ==
func set_powerup(value: StringName) -> void:
	if !is_node_ready(): # To make sure the powerup is safely got
		current_powerup = value
		return
	
	var matched_powerup: bool = false
	for i in get_children():
		if !i is MarioPowerup:
			continue
		
		i = i as MarioPowerup # To get code hints
		if i.powerup_id == value:
			current_powerup = value
			i.visible = true
			i.process_mode = PROCESS_MODE_INHERIT # Activates the process of target powerup
			i._powerup_entered()
			no_appearing_animation_when_ready = false
			_powerup = i
			matched_powerup = true
		else:
			i.visible = false
			i.process_mode = PROCESS_MODE_DISABLED # Deactivates the process of other powerups
			i._powerup_exited()
	if !matched_powerup:
		_powerup = null
#endregion

#region == Status Control ==
## Makes the character invulerable from the damage by enemies.
func invulnerablize(duration: float = 2) -> void:
	_invulnerablity_counter = get_tree().create_timer(duration, false)
	_invulnerablity_counter.timeout.connect(
		func() -> void:
			_invulnerablity_counter = null
	)
	Effects.flash(self, duration)

## Makes the character hurt.[br]
## By default, this call will be blocked if [param forced] is [code]false[/code] while the character has been invulnerable.[br]
## If [param invincibility] is passed in with [code]false[/code], the character won't be invulnerable because of this call.[br]
## [param override_down_to] can be set to non-empty values, but needs to be a valid id of existing powerups for the character.
func hurt(duration: float = 2, forced: bool = false, invincibility: bool = true, override_down_to: StringName = &"") -> void:
	if !forced && is_invulnerable():
		return
	if !_powerup:
		return
	
	if !override_down_to.is_empty():
		Sound.play_2d(_powerup.sound_hurt, self)
		current_powerup = override_down_to
	elif !_powerup.down_to_powerup_id.is_empty():
		Sound.play_2d(_powerup.sound_hurt, self)
		current_powerup = _powerup.down_to_powerup_id
	else:
		die()
		return
	
	if invincibility:
		invulnerablize(duration)

## Makes the character die.
func die() -> void:
	_death.visible = true
	
	if _powerup:
		_death.sound_death = _powerup.sound_death
		_death.process_mode = Node.PROCESS_MODE_INHERIT
	
	(func() -> void:
		_death.reparent(get_parent())
		get_parent().move_child(_death, get_index())
		_death.death_effect_start()
	).call_deferred()
	
	remove_from_group(&"character")
	queue_free()

## Returns [code]true[/code] if the character is invulnerable.
func is_invulnerable() -> bool:
	return is_instance_valid(_invulnerablity_counter)
#endregion


#region == General Getters ==
## Returns the current powerup
func get_current_powerup() -> MarioPowerup:
	return _powerup if is_instance_valid(_powerup) else null
#endregion
