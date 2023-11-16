extends "./mario_behavior_default.gd"

@export_category("Mario Behavior Lui")
@export var phantom_creator: Node
@export_enum("Never", "Always", "Walking", "In the Air") var phantom_activated_mode: int = 3


func _process(_delta: float) -> void:
	super(_delta)
	
	if !phantom_creator:
		return
	
	match phantom_activated_mode:
		0:
			phantom_creator.process_mode = PROCESS_MODE_DISABLED
		1:
			phantom_creator.process_mode = process_mode
		2:
			phantom_creator.process_mode = process_mode if mario.is_on_floor() && mario.speed > 0 else PROCESS_MODE_DISABLED
		3:
			phantom_creator.process_mode = process_mode if !mario.is_on_floor() else PROCESS_MODE_DISABLED
