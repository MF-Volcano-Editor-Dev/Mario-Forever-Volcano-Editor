extends EntityBody2D

## Emitted when the bumping times runs out
signal run_out

@export_category("Bumper")
@export_range(0, 50, 1, "or_greater", "suffix:times") var bumping_times: int = 3:
	set(value):
		bumping_times = clampi(value, 0, 50)
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var bumping_bouncing_speed: float = 300
@export_range(1, 20, 0.001, "or_greater", "suffix:s") var duration: float = 10
@export_group("Sounds", "sound_")
@export var sound_bumping: AudioStream = preload("res://assets/sounds/stun.wav")


func _ready() -> void:
	collided_floor.connect(bump)
	collided_ceiling.connect(bump)
	collided_wall.connect(bump)
	
	get_tree().create_timer(duration).timeout.connect(
		func() -> void:
			var tw := create_tween()
			tw.tween_property(self, ^"modulate:a", 0, 0.25)
			tw.finished.connect(queue_free)
	)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func bump(sound: bool = true) -> void:
	if sound:
		Sound.play_sound_2d(self, sound_bumping)
	
	bumping_times -= 1
	if bumping_times <= 0:
		collision_mask = 0
		run_out.emit()
	
	if is_on_floor() || is_falling():
		jump(bumping_bouncing_speed)
	elif is_on_ceiling():
		velocity.y = 0
