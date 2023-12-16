class_name EnemyDeath extends Instantiater2D

signal death_stomped_created ## Emitted when [member death_stomped] is created
signal death_killed_created ## Emitted when [member death_attacked] is created

@export_category("General Death Instantiater")
@export_group("Deaths")
@export_subgroup("Stomped")
@export var death_stomped: PackedScene
@export var death_stomped_offset: Vector2
@export_subgroup("Killed")
@export var death_killed: PackedScene
@export var death_killed_offset: Vector2
@export_group("Sounds", "sound_")
@export var sound_stomped: AudioStream = preload("res://assets/sounds/stomp.wav")
@export var sound_killed: AudioStream = preload("res://assets/sounds/kick.wav")


#region == Stomped and killed ==
func stomped_to_death(with_sound: bool = true) -> void:
	if with_sound:
		Sound.play_sound_2d(_root, sound_stomped)
	instantiate(death_stomped, death_stomped_offset)
	death_stomped_created.emit()

func killed_to_death(with_sound: bool = true) -> void:
	if with_sound:
		Sound.play_sound_2d(_root, sound_killed)
	instantiate(death_killed, death_killed_offset)
	death_killed_created.emit()
#endregion
