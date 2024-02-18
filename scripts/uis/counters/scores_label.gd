@tool
extends "./counter_label.gd"

@export_category("Scores Label")
@export var change_relevant_data: bool = true


func _ready() -> void:
	super()
	
	if Engine.is_editor_hint():
		return
	if !change_relevant_data:
		return
	
	Character.Data.scores += amount
