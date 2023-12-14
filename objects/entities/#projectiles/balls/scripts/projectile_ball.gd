class_name ProjectileBall extends Classes.HiddenEntityBody2D

signal run_out ## Emitted when [member jumping_times] is zero when the ball jumps, or when [method notify_run_out] is called.

@export_category("Projectile Ball")
@export_range(0, 100, 1) var jumping_times: int = 20
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix") var jumping_speed: float = 250
@export_group("Sounds", "sound_")
@export var sound_jumping: AudioStream


func _physics_process(delta: float) -> void:
	move_and_slide()


#region == Jumping ball ==
## Makes the ball jump and count down 1 from [member jumping_times]
func ball_jump() -> void:
	Sound.play_sound_2d(self, sound_jumping)
	jump(jumping_speed)
	# Jumping to explode
	jumping_times -= 1
	if jumping_times <= 0:
		notify_run_out()

## Emits the signal [signal run_out]
func notify_run_out() -> void:
	run_out.emit()
#endregion
