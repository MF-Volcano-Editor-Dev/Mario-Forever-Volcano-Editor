class_name Mario extends Character

## Character that behaves similarly to Mario
##
##

@export var current_powerup: StringName = &"small":
	set = set_powerup
@export var no_appearing_animation_when_ready: bool = true

var _powerup: MarioPowerup # Current powerup


func _ready() -> void:
	current_powerup = current_powerup # Triggers "set_powerup" to set initial powerup


#region == Setgets ==
func set_powerup(value: StringName) -> void:
	if !is_node_ready(): # To make sure the powerup is safely got
		return
	
	for i in get_children():
		if !i is MarioPowerup:
			continue
		
		i = i as MarioPowerup # To get code hints
		if i.powerup_id == value:
			current_powerup = value
			i.process_mode = PROCESS_MODE_INHERIT # Activates the process of target powerup
			i._powerup_entered()
			no_appearing_animation_when_ready = false
		else:
			i.process_mode = PROCESS_MODE_DISABLED # Deactivates the process of other powerups
			i._powerup_exited()
#endregion


#region == General Getters ==
## Returns the current powerup
func get_current_powerup() -> MarioPowerup:
	return _powerup if is_instance_valid(_powerup) else null
#endregion
