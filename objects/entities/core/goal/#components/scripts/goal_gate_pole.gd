extends EntityBody2D

const GoalGate := preload("../../scripts/goal_gate.gd")

@export_category("Goal Gate Pole")
@export_group("Physics")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_speed: float = 300
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var initial_speed_randomizer: float = 100
@export_range(-18000, 18000, 0.001, "suffix:°/s") var rotation_speed: float = 1000
@export_group("Scores")
@export var scores: Array[int] = [100, 200, 500, 1000, 2000, 5000, 10000]

@onready var gate: GoalGate = $"../.."
@onready var area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var scores_adder: Classes.ScoresAdder = $ScoresAdder

var direction: int


func _ready() -> void:
	set_physics_process(false)
	
	area.body_entered.connect(_on_player_touched_pole)


func _physics_process(delta: float) -> void:
	sprite.rotate(direction * deg_to_rad(rotation_speed) * delta)
	move_and_slide()


func _on_player_touched_pole(body: Node2D) -> void:
	if !body is EntityPlayer2D:
		return
	
	gate.player_touch_goal(body, true)
	gate.pole_scores(scores)
	gate.area_global.queue_free()
	area.queue_free()
	
	direction = gate.direction
	global_velocity = Vector2(direction, -1).normalized().rotated(gate.global_rotation + randf_range(-PI/12, PI/12)) * randf_range(initial_speed - initial_speed_randomizer, initial_speed + initial_speed_randomizer)
	
	set_physics_process(true)
