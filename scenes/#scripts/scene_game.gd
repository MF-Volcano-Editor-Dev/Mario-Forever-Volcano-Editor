@icon("res://icons/scene_game.svg")
class_name SceneGame extends Node2D

## Abstract class used for game rooms
## 
## Stage, Map extends from this class


func _ready() -> void:
	Data.data_init_signal_emit() # Emits the notice to initialize the data of players
