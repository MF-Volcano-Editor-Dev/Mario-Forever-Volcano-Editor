@tool
extends "./counter_label.gd"

@export_category("Scores Label")
@export var change_scores_data: bool = true


func _ready() -> void:
	super()
	
	if Engine.is_editor_hint():
		return
	if !change_scores_data:
		return
	
	Character.Data.scores += amount
