@tool
extends "./scores_label.gd"


func _ready() -> void:
	super()
	
	if Engine.is_editor_hint():
		return
	if !change_relevant_data:
		return
	
	Character.Data.lives += amount
