class_name MarioSuit2D extends Node2D

@export_group("General")
@export var character_id: StringName = &"mario"
@export var suit_id: StringName = &"small"

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer
