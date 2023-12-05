class_name CharacterPower2D extends Classes.HiddenNode2D

signal power_current ## Emitted when the power is current
signal power_backrun ## Emitted when the power is not current

@export_category("Mario Suit")
@export_group("Component Links", "path_")
@export_node_path("Node2D") var path_sprite: NodePath = ^"Sprite2D"
@export_node_path("AnimationPlayer") var path_animation: NodePath = ^"AnimationPlayer"
@export_group("Power Data")
## Level of the suit
@export_range(-5, 5, 1) var power_level: int
@export var power_id: StringName = &"small"
@export var power_down_to_id: StringName
@export_subgroup("States")
@export var is_small: bool
@export_group("Sounds", "sound_")
@export var sound_hurt: AudioStream = preload("res://assets/sounds/power_down.wav")
@export var sound_death: AudioStream = preload("res://assets/sounds/death.ogg")

#@onready var _sprite := get_sprite()
@onready var _animation := get_animation() as AnimationPlayer
#@onready var _behaviors := get_behaviors()


#region == Animation ==
func appear() -> void:
	if !_animation:
		return
	_animation.play(&"appear")
	get_tree().create_timer(1, false).timeout.connect(_animation.play.bind(&"RESET"))
#endregion

#region == Getters ==
func get_sprite() -> Node2D:
	return get_node_or_null(path_sprite) as Node2D

func get_animation() -> AnimationPlayer:
	return get_node(path_animation) as AnimationPlayer
#endregion
