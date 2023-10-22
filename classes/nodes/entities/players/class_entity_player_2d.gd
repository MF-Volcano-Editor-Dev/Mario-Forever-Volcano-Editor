class_name EntityPlayer2D extends EntityBody2D

## Class of platform-game players, mainly for [Mario2D]
##
## This class supports multiple players via differnet [member id]s, and developers
## can change the [member nickname] of the player so that the name can be shown without
## effecting the [member character_name]

signal got_hurt
signal got_death

@export_group("Core")
@export_range(0, 3) var id: int
@export var character_id: StringName = &"mario":
	set = set_character_id
@export_group("Information")
@export var nickname: StringName = &"Player"
@export_group("Physics")
@export_enum("Left: -1", "Right: 1") var direction: int = 1

var state_machine: StateMachine = StateMachine.new()

@onready var _default_process_mode: ProcessMode = process_mode


func _ready() -> void:
	pass


#region Status Controls
func enable() -> void:
	process_mode = _default_process_mode


func disable() -> void:
	process_mode = PROCESS_MODE_DISABLED
#endregion


#region Damage Controls
func hurt() -> void:
	got_hurt.emit()


func die() -> void:
	got_death.emit()
#endregion


#region Setters & Getters
func set_character_id(new_character_id: StringName) -> void:
	character_id = new_character_id
#endregion
