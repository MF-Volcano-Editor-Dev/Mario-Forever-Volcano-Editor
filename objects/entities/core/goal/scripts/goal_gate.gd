extends Node2D

@export_category("Goal Gate")
@export var goal_walking_finished_line: Node

@onready var area_global: Area2D = $Area2D
@onready var shape_border: CollisionShape2D = $Area2D/Border
@onready var shape_rect: CollisionShape2D = $Area2D/Rect


func _ready() -> void:
	area_global.body_entered.connect(_on_player_entered)


func _on_player_entered(body: Node2D) -> void:
	if !body is EntityPlayer2D:
		return
	
	EventsManager.level_finish()
