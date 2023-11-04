extends Component

## Emitted when [method disappear] gets called
signal disappear_started

## Emitted when [method disappear] ends
signal disappear_ended

@export_category("Goomba Stomped")
@export_group("Disappear")
@export_range(0, 10, 0.001, "suffix:s") var disappear_delay: float = 2
@export_group("Sounds", "sound_")
@export var sound_player: Sound2D
@export var sound_stomped: AudioStream = preload("res://assets/sounds/stomp.wav")


func disappear() -> void:
	if !root is Node2D:
		return
	
	disappear_started.emit()
	
	if sound_player:
		sound_player.play_sound(sound_stomped, get_tree().current_scene)
	
	var tw: Tween = root.create_tween()
	tw.tween_interval(disappear_delay)
	tw.tween_property(root, "modulate:a", 0, 0.25)
	
	await tw.finished
	
	disappear_ended.emit()
