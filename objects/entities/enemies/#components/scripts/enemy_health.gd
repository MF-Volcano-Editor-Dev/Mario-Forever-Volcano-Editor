extends Component

## Emitted when [method killed] gets called
signal got_killed

## Emitted when [method killed] gets called without combower
signal got_killed_no_combo

## Emitted when [method blocked] gets called
signal got_blocked

@export_category("Enemy Health")
@export_range(1, 2, 0.01, "or_greater", "hide_slider", "suffix:♥") var hp: float = 1:
	set(value):
		hp = clampf(value, 0, INF)
@export_group("Sounds", "sound_")
@export var sound_player: Sound2D
@export var sound_blocked: AudioStream = preload("res://assets/sounds/bump.wav")
@export var sound_hurt: AudioStream = preload("res://assets/sounds/kick.wav")
@export var sound_killed: AudioStream = preload("res://assets/sounds/kick.wav")

var _is_killed: bool

#region Attack process
func killed(attacker: Classes.Attacker) -> void:
	#region Special Attacks 
	if &"combower" in attacker.attacker_features:
		# HP
		if !_damage_process(attacker.attacker_damage):
			attacker.receiver_body_called_back.emit(self)
			return
		
		got_killed.emit()
		return
	
	if &"ice_freezing" in attacker.attacker_features:
		return
	#endregion
	
	
	#region Normal Attack
	# HP
	if !_damage_process(attacker.attacker_damage):
		attacker.receiver_body_called_back.emit(self)
		return
	
	# Killing process
	_is_killed = true
	
	if sound_player:
		sound_player.play_sound(sound_killed, get_tree().current_scene)
	
	got_killed.emit()
	got_killed_no_combo.emit()
	#endregion


func blocked(_attacker: Classes.Attacker) -> void:
	if sound_player:
		sound_player.play_sound(sound_blocked, get_tree().current_scene)
	got_blocked.emit()


func destroy_after_being_killed() -> void:
	if !_is_killed:
		return
	root.queue_free()
#endregion


#region Private Methods
func _damage_process(damage: float) -> bool:
	hp -= damage
	if hp > 0:
		if sound_player:
			sound_player.play_sound(sound_killed, get_tree().current_scene)
		return false
	return true
#endregion
