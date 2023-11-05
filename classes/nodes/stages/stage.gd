class_name Stage extends Node2D

## Class used for stages
##
##

## Emitted when the level is finished
signal stage_finished(with_players: Array[EntityPlayer2D])

@export_group("Finish")
@export_range(0, 10, 0.001, "suffix:s") var finish_process_delay: float = 4
## Scene to go after the stage finished is emitted
@export var scene_after_finish: PackedScene

var _after_finish_wait_nodes: Array[Node]


func _enter_tree() -> void:
	EventsManager.signals.level_finished.connect(_on_level_finished.unbind(1))


#region Todo List after Finish
func add_node_to_wait_finish(node: Node) -> void:
	if node in _after_finish_wait_nodes:
		return
	_after_finish_wait_nodes.append(node)


func remove_node_to_wait_finish(node: Node) -> void:
	if !node in _after_finish_wait_nodes:
		return
	_after_finish_wait_nodes.erase(node)
#endregion


func _on_level_finished() -> void:
	await get_tree().create_timer(finish_process_delay, false).timeout
	
	while !_after_finish_wait_nodes.is_empty():
		await get_tree().process_frame
	
	if scene_after_finish:
		get_tree().change_scene_to_packed(scene_after_finish)
	else:
		printerr("[Scene Jumping Error] The scene to be warped to is invalid or not set yet!")
