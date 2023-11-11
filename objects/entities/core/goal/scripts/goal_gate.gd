extends Node2D

const GoalGatePole := preload("../#components/scripts/goal_gate_pole.gd")

@export_category("Goal Gate")
@export_enum("Left: -1", "Right: 1") var direction: int = -1:
	set(value):
		direction = clampi(value, -1, 1)
		if direction == 0:
			direction = [-1, 1].pick_random()
@export var detection_rect: bool = true
@export var goal_walking_finished_line: Node

@onready var components: Node2D = $Components
@onready var area_global: Area2D = $Components/Area2D
@onready var shape_border: CollisionShape2D = $Components/Area2D/Border
@onready var shape_rect: CollisionShape2D = $Components/Area2D/Rect
@onready var goal_gate_pole: GoalGatePole = $Components/GoalGatePole
@onready var pos_gate_top: Marker2D = $Components/PosGateTop
@onready var animation_pole: AnimationPlayer = $AnimationPole
@onready var goal_gate_detector: AnimatedSprite2D = $Components/GoalGateDetector
@onready var gate_left: Sprite2D = $Components/GateLeft
@onready var gate_right: Sprite2D = $Components/GateRight


func _ready() -> void:
	shape_border.set_deferred(&"disabled", detection_rect)
	shape_rect.set_deferred(&"disabled", !detection_rect)
	
	area_global.body_entered.connect(player_touch_goal)
	components.scale.x *= -direction
	
	if components.scale.x < 0:
		goal_gate_detector.scale.x *= -1
		gate_left.scale.x *= -1
		gate_right.scale.x *= -1


func player_touch_goal(body: Node2D, from_pole: bool = false) -> void:
	if !body is EntityPlayer2D:
		return
	
	if !from_pole:
		animation_pole.pause()
		area_global.queue_free()
		goal_gate_pole.area.queue_free()
		
		goal_gate_pole.scores_lives_adder.scores = 100
		goal_gate_pole.scores_lives_adder.add_score()
	
	EventsManager.level_finish()


# Called by the pole "_on_player_touched_pole()"
func pole_scores(scores: Array[int]) -> void:
	var scrsize := scores.size()
	var anmpos := animation_pole.current_animation_position
	var anmlen := animation_pole.current_animation_length
	var slice := anmlen / float(scrsize)
	
	for i in scrsize:
		var sect: Vector2 = Vector2(slice * i, slice * (i + 1))
		if anmpos < sect.x || anmpos > sect.y:
			continue
		
		goal_gate_pole.scores_lives_adder.scores = scores[i]
		goal_gate_pole.scores_lives_adder.add_score()
		animation_pole.queue_free()
		break

