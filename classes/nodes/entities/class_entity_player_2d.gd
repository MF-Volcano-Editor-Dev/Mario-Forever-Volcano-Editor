class_name EntityPlayer2D extends EntityBody2D


@export_group("General")
@export_range(0, 3) var id: int
@export var nickname: StringName = &"Player"
@export_enum("Left: -1", "Right: 1") var direction: int = 1


func _ready() -> void:
	pass
