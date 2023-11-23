class_name CharacterPower2D extends Classes.HiddenNode2D

@export_category("Mario Suit")
@export_group("Component Links", "path_")
@export_node_path("AnimationPlayer") var path_shape_controller: NodePath
@export_node_path("Node2D") var path_sprite: NodePath = ^"Sprite2D"
@export_node_path("AnimationPlayer") var path_animation: NodePath = ^"AnimationPlayer"
@export_node_path("Node") var path_behavior: NodePath = ^"Behavior"
@export_group("Power Data")
## Level of the suit
@export_range(-5, 5, 1) var power_level: int
@export var power_id: StringName = &"small"
@export var powdown_to_id: StringName
@export_group("Sounds", "sound_")
@export var sound_hurt: AudioStream = preload("res://assets/sounds/power_down.wav")
@export var sound_death: AudioStream = preload("res://assets/sounds/death.ogg")

# Node getting
@onready var shape_controller := get_node_or_null(path_shape_controller) as AnimationPlayer
@onready var sprite := get_node_or_null(path_sprite) as Node2D
@onready var animation := get_node(path_animation) as AnimationPlayer
@onready var behavior := get_node(path_behavior) as CharacterBehavior2D


#region == Animation ==
func appear() -> void:
	if !animation:
		return
	animation.play(&"appear")
	get_tree().create_timer(1, false).timeout.connect(animation.play.bind(&"idle"))
#endregion
