extends Component

## Emitted when [method killed] gets called
signal got_killed

## Emitted when [method killed] gets called without combower
signal got_killed_no_combo

## Emitted when [method blocked] gets called
signal got_blocked

@export_category("Goomba Killed")
@export_range(1, 2, 0.01, "or_greater", "hide_slider", "suffix:♥") var hp: float = 1:
	set(value):
		hp = clampf(value, 0, INF)
@export_group("Damaged")
@export_subgroup("Velocity")
@export var thrown_direction: Vector2 = Vector2.UP
@export_range(0, 90, 0.001, "degrees") var max_angle: float = 30
@export var global_velocity: Dictionary = {
	accordance = "",
	min_value = 50.0,
	max_value = 200.0
}
@export_subgroup("Rotation")
@export var sprite: Node2D
@export_range(-18000, 18000, 0.001, "suffix:°/s") var rotation_speed: float = 125
@export_group("Sounds", "sound_")
@export var sound_player: Sound2D
@export var sound_blocked: AudioStream = preload("res://assets/sounds/bump.wav")
@export var sound_hurt: AudioStream = preload("res://assets/sounds/kick.wav")
@export var sound_killed: AudioStream = preload("res://assets/sounds/kick.wav")

var _is_killed: bool


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
		sound_player.play_sound(sound_killed)
	
	if root is Node2D:
		var a: float = 0.0
		while !a:
			a = randf_range(-max_angle, max_angle)
		
		var v: Vector2 = thrown_direction.rotated(root.global_rotation + deg_to_rad(a))
		if global_velocity.accordance:
			root.set(global_velocity.accordance, v * randf_range(global_velocity.min_value, global_velocity.max_value))
		
		if rotation_speed && sprite:
			# Used a Tween for process
			var tw: Tween = sprite.create_tween().set_loops()
			tw.tween_property(sprite, "rotation", signf(a) * TAU, (TAU * 50  / deg_to_rad(rotation_speed)) * Process.get_delta(self))
	
	got_killed.emit()
	got_killed_no_combo.emit()
	#endregion


func blocked(_attacker: Classes.Attacker) -> void:
	if sound_player:
		sound_player.play_sound(sound_blocked)
	got_blocked.emit()


func killed_to_destroy() -> void:
	if !_is_killed:
		return
	root.queue_free()


#region Private Methods
func _damage_process(damage: float) -> bool:
	hp -= damage
	if hp > 0:
		if sound_player:
			sound_player.play_sound(sound_killed)
		return false
	return true
#endregion
