extends Node

@export var start_scene: PackedScene = preload("res://scenes/templates/level.tscn")


func _enter_tree() -> void:
	if !start_scene:
		printerr("Lack of start scene, the game will quit for 3 seconds!")
		
		await get_tree().create_timer(3, false).timeout
		
		get_tree().quit()
		return
	
	get_tree().change_scene_to_packed.call_deferred(start_scene)
