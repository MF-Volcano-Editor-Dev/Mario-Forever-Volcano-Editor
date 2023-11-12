extends AnimatedSprite2D

const GoalGate := preload("../../scripts/goal_gate.gd")

@onready var gate: GoalGate = $"../.."
@onready var pos_gate_top: Marker2D = $"../PosGateTop"
@onready var shape_border: CollisionShape2D = $"../Area2D/Border"
@onready var shape_rect: CollisionShape2D = $"../Area2D/Rect"


func _ready() -> void:
	shape_border.position = Vector2(position.x + 16, 0)
	shape_rect.position = Vector2(position.x / 2 + 16, 0)
	shape_rect.scale = Vector2(position.x, 2)
