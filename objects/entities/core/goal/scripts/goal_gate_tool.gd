@tool
extends Node2D


func _ready() -> void:
	if !Engine.is_editor_hint():
		queue_free()


func _process(_delta: float) -> void:
	var dir: int = -get_parent().direction
	$"../Components".scale.x = dir
	$"../Components/GateLeft".scale.x = dir
	$"../Components/GateRight".scale.x = dir
	$"../Components/GoalGateDetector".scale.x = dir
