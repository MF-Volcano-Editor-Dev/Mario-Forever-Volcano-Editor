@tool
extends Node2D

enum _OrbsPlacement {
	BAR,
	CIRCLE,
	SPIRAL
}

@export_category("Orb")
@export var preview: bool:
	set = set_preview

var _orb_data: Array[OrbData]


func _enter_tree() -> void:
	for i in get_children(): # Reset the position of orbs to this object to makes their origin proper
		if !&"Orb" in i.name || !i is CircularMovementObject2D:
			continue
		i.position = Vector2.ZERO

func _process(delta: float) -> void:
	_run_orbs(delta)


func _run_orbs(delta: float) -> void:
	if !Engine.is_editor_hint():
		return
	
	if !get_child_count():
		return
	
	for i in get_children():
		if !&"Orb" in i.name || !i is CircularMovementObject2D:
			continue
		
		var orb := i as CircularMovementObject2D
		_update_orb_pos(orb)
		
		if !preview:
			continue
		
		var f := orb.frequency * delta
		var t := orb.track_rotation_speed * delta
		
		orb.phase = wrapf(orb.phase + f, -180, 180)
		orb.track_angle = wrapf(orb.track_angle + t, -180, 180)

func _update_orb_pos(orb: CircularMovementObject2D) -> void:
	var ang := deg_to_rad(orb.phase)
	orb.position = Vector2(
		orb.amplitude.x * cos(ang),
		orb.amplitude.y * sin(ang)
	).rotated(deg_to_rad(orb.track_angle))


func set_preview(value: bool) -> void:
	if !Engine.is_editor_hint():
		return
	
	preview = value
	
	if !is_node_ready():
		await ready
	
	if preview:
		for i in get_children():
			if !&"Orb" in i.name || !i is CircularMovementObject2D:
				continue
			
			var orb := i as CircularMovementObject2D
			var tw: Tween = null
			
			if orb.amplitude_changing_speed > 0:
				# Average values
				var avr_amplitude := (absf(orb.amplitude_max.x - orb.amplitude.x) + absf(orb.amplitude_max.y - orb.amplitude.y)) / 2
				# Tween (Using average values)
				tw = i.create_tween().set_trans(i.amplitude_changing_mode).set_loops()
				tw.tween_property(i, ^"amplitude", i.amplitude_max, avr_amplitude / i.amplitude_changing_speed)
				tw.tween_property(i, ^"amplitude", orb.amplitude, avr_amplitude / i.amplitude_changing_speed)
				print(tw)
			
			_orb_data.append(OrbData.new(orb, orb.phase, orb.track_angle, orb.amplitude, tw))
	else:
		var orbs := get_children()
		
		for j in orbs:
			if !&"Orb" in j.name || !j is CircularMovementObject2D:
				continue
			for k in _orb_data: # Iterates the orb datas to find matching one
				if k.orb != j: # Skip dismatched orb data
					continue
				for l in k.properties:
					j.set(l, k.properties[l])
			
			_update_orb_pos(j) # Moves the orb to the position before preview was turned on
		
		_orb_data.clear()



class OrbData:
	var orb: CircularMovementObject2D
	var tweener: Tween
	var properties: Dictionary = {
		phase = 0.0,
		track_angle = 0.0,
		amplitude = Vector2.ZERO,
	}
	
	func _init(p_orb: CircularMovementObject2D, phase: float, track_angle: float, amplitude: Vector2, p_tweener: Tween) -> void:
		orb = p_orb
		tweener = p_tweener
		properties.phase = phase
		properties.track_angle = track_angle
		properties.amplitude = amplitude
	
	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			if is_instance_valid(tweener):
				print(tweener, "is deleted!")
				tweener.kill()
				tweener = null
