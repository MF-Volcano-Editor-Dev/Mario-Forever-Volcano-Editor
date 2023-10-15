class_name EntityPlayer2D extends EntityBody2D


@export_group("General")
@export_range(0, 3) var id: int
@export var nickname: StringName = &"Player"
@export_enum("Left: -1", "Right: 1") var direction: int = 1

@onready var state_machine: StateMachine = StateMachine.new()
@onready var effects_2d: Effects2D = Effects2D.new()


func _ready() -> void:
	pass
