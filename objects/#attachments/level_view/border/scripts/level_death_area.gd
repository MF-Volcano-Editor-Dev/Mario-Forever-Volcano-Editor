extends CanvasLayer

@export_category("Death Area")
@export_group("Transform")
@export_flags("Global Position", "Global Rotation", "Global Scale") var transform_tracking: int = 8
@export_group("Player Death")
@export var player_death_tags: Dictionary

@onready var death_area: Area2D = $DeathArea


func _ready() -> void:
	death_area.area_entered.connect(
		func(area: Area2D) -> void:
			var pl := area.get_parent()
			if pl is EntityPlayer2D:
				pl.die(player_death_tags)
	)
