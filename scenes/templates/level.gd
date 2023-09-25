extends Node2D

func _ready() -> void:
	CallRules.obey(self, "entity")


func move(delta: float) -> void:
	pass
