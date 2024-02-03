@tool
extends Node2D

const _COUNTER: Script = preload("res://scripts/uis/counters/counter_label.gd")

signal completion_triggered ## Emitted when the level completion is successfully triggered.
signal completion_restored ## Emitted when the level completion is restored.

@export_category("Goal")
## The facing direction of goal.
@export_enum("Left:-1", "Right:1") var facing: int = -1:
	set(value):
		facing = value
		scale.x *= -absf(facing)
## The shape of detection area:[br]
## [b]* Rectangle:[/b] This requires a goal pre-detector so as to make sure the shape can be determined by both the position of pre-detector and the position of goal. Once a character goes into the rectangle, the detection is successful.[br]
## [b]* Infinite:[/b] In this shappe, as long as a character moves to the back of goal's middle, the detection is successful.
@export_enum("Rectangle", "Infinite") var detection_area_shape: int = 0:
	set(value):
		detection_area_shape = value
		$CompletionDetc/Rectangle.set_deferred(&"disabled", detection_area_shape != 0)
		$CompletionDetc/Infinite.set_deferred(&"disabled", detection_area_shape != 1)
@export_group("Score")
## Scores according to the position of the pole.
@export var scores: PackedInt32Array = [200, 500, 1000, 2000, 5000, 10000]
## Score to be given if a character fails hitting down the pole.
@export_range(0, 10000, 1) var default_score: int = 100
@export_group("References")
@export_node_path("Node") var level_completion_path: NodePath = ^"../LevelCompletion"

var _has_completed: bool # If true, the complete_level() is not callable, and the pole is unhittable as well.
var _hit_pole: bool # If true, the score will be `default_score`

@onready var _sprite_gate: Node2D = $SpriteGate
@onready var _completion_detection: Area2D = $CompletionDetc
@onready var _completion_area_rectangle: CollisionShape2D = $CompletionDetc/Rectangle
@onready var _completion_area_rectangle_disabled: bool = _completion_area_rectangle.disabled
@onready var _completion_area_infinite: CollisionShape2D = $CompletionDetc/Infinite
@onready var _completion_area_infinite_disabled: bool = _completion_area_rectangle.disabled
@onready var _instantiater_2d: Instantiater2D = $Instantiater2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _level_completion: = get_node_or_null(level_completion_path)


## Triggers the completion of current level.
func complete_level(body: Node2D) -> void:
	if _has_completed:
		return
	if !Character.Checker.is_character(body):
		return
	
	_has_completed = true
	
	_completion_area_rectangle.set_deferred(&"disabled", true)
	_completion_area_infinite.set_deferred(&"disabled", true)
	
	# TODO: Level completion
	
	var section: int = mini(0, scores.size() * int(roundf(_animation_player.current_animation_position / _animation_player.current_animation_length)) - 1) # Get which score the character can attain
	Character.Data.scores += scores[section]
	(_instantiater_2d.instantiate(0) as _COUNTER).amount = scores[section] if _hit_pole else default_score
	
	_animation_player.pause()
	
	completion_triggered.emit()
