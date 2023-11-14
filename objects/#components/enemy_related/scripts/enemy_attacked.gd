extends Classes.HealthComponent

## Emitted when [method killed] gets called
signal attacked_successfully

## Emitted when the enemy is attacked to death
signal attacked_to_death

## Emitted when the enemy is attacked to death without combo [br]
## [b]Note:[/b] This will be emitted together with [signal attacked_to_death]
signal attacked_to_death_no_combo

## Emitted when [method blocked] gets called
signal attack_blocked

@export_category("Enemy Attacked")
@export_group("Sounds", "sound_")
@export var sound_blocked: AudioStream = preload("res://assets/sounds/bump.wav")
@export var sound_hurt: AudioStream = preload("res://assets/sounds/kick.wav")
@export var sound_killed: AudioStream = preload("res://assets/sounds/kick.wav")


#region Attack process
func killed(attacker: Classes.Attacker) -> void:
	#region Special Attacks 
	if &"combo" in attacker.attacker_features:
		# HP
		sub_health(attacker.attacker_damage)
		attacked_successfully.emit()
		_health_zero(true)
		
		return
	
	if &"ice_frozen" in attacker.attacker_features:
		return
	#endregion
	
	
	#region Normal Attack
	# HP
	sub_health(attacker.attacker_damage)
	attacked_successfully.emit()
	_health_zero(false)
	#endregion


func blocked(_attacker: Classes.Attacker) -> void:
	Sound.play_sound_2d(root, sound_blocked)
	attack_blocked.emit()


func _health_zero(combo: bool) -> void:
	if health <= 0:
		if !combo:
			Sound.play_sound_2d(root, sound_killed)
		
		attacked_to_death.emit()
		if !combo:
			attacked_to_death_no_combo.emit()
	else:
		Sound.play_sound_2d(root, sound_hurt)
