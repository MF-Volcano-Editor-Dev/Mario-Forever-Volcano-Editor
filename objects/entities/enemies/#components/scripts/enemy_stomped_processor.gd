extends Component

## Emitted when the node is about to disappear
signal disappeared

@export_category("Stomped Processor")
@export_group("Disappearance")
@export_range(0, 100, 0.01, "suffix:s") var disappearing_delay: float = 2
@export_group("Sounds", "sound_")
@export var sound: Sound2D
@export var sound_stomped: AudioStream = preload("res://assets/sounds/stomp.wav")


func play_stomping_sound() -> void:
	if !sound:
		return
	sound.play(sound_stomped, get_tree().current_scene)


func disappear() -> void:
	if disappearing_delay > 0 && root is Node2D:
		await get_tree().create_timer(disappearing_delay, false).timeout
		
		var tw := root.create_tween()
		tw.tween_property(root, "modulate:a", 0.0, 0.25)
		await tw.finished
		
		disappeared.emit()
