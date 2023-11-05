class_name EntityPlayer2D extends EntityBody2D

## Class of platform-game players, mainly for [Mario2D]
##
## This class supports multiple players via differnet [member id]s, and developers
## can change the [member nickname] of the player so that the name can be shown without
## effecting the [member character_name]

## Emitted when the player gets hurt
signal got_hurt
## Emitted when the player gets death
signal got_death

@export_group("Core")
## Id of the player, used to separate different players,
## especially when there is multiple players and you need
## to make their controls independent from each other
@export_range(0, 3) var id: int
## Character ID of the player, used to sign the data
## of the same kind of player. This is mainly used in
## [Mario2D] to store suits for the same character.[br]
## [b]Note:[/b] Do NOT change this id unless you are going to
## make a new character
@export var character_id: StringName = &"mario":
	set = set_character_id
## If [code]true[/code], the player will be active and processible
@export var active: bool = true:
	set(value):
		active = value
		process_mode = PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED
@export_group("Information")
## Name of the player to display in the game. This can be edited
## When a game user wants to show a personal name
@export var nickname: StringName = &"Player"
@export_group("Physics")
## Direction of the player. [br]
## [b]Note:[/b] The value of this property WILL NEVER BE ZERO.
@export_enum("Left: -1", "Right: 1") var direction: int = 1:
	set(to):
		direction = to
		if direction == 0:
			direction = [-1, 1].pick_random()

## [StateMachine] for the player
var state_machine: StateMachine = StateMachine.new()

@onready var _default_process_mode: ProcessMode = process_mode


func _ready() -> void:
	pass


#region Status Controls
## Enables the runtime of the player
func enable() -> void:
	process_mode = _default_process_mode

## Disables the player from the runtime
## [b]Caution![/b] This would include not only [method Node._process] and [method Node._physics_process],
## but also some initial methods like [method Node._ready]
func disable() -> void:
	process_mode = PROCESS_MODE_DISABLED
#endregion


#region Damage Controls
## Abstract method to make the player hurt [br]
## [b]Note 1:[/b] Sometimes you need to emit the signal [signal got_hurt]
## [b]Note 2:[/b] Sometimes you are required to check the list for [param _tags] in child classes
func hurt(_tags: Dictionary = {}) -> void:
	pass

## Abstract method to make the player die [br]
## [b]Note 1:[/b] Sometimes you need to emit the signal [signal got_death]
## [b]Note 2:[/b] Sometimes you are required to check the list for [param _tags] in child classes
func die(_tags: Dictionary = {}) -> void:
	pass
#endregion


#region Setters & Getters
## Sets the [member character_id] of the player, often overridden by extending class,
## especially the [Mario2D] when changing the suit
func set_character_id(new_character_id: StringName) -> void:
	character_id = new_character_id
#endregion
