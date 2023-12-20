@icon("res://icons/scene_game.svg")
class_name SceneGame extends Node2D

## Abstract class used for game rooms
## 
## Stage, Map extends from this class


func _enter_tree() -> void:
	Scenes.cache_scene(scene_file_path)

func _ready() -> void:
	Data.get_player_data().data_init_signal_emit() # Emits the notice to initialize the data of players
