@tool
extends Label

@export_category("Counter")
## Number to display
@export var amount: int:
	set(value):
		amount = value
		
		text = str(amount) + str(suffix)
		modulate = Color.WHITE
		
		if amount < 0:
			text = text.replacen("-", "") + str(suffix)
			modulate = Color(1, 0.25, 0, modulate.a)
## Suffix of the number to display
@export_placeholder("Suffix") var suffix: String:
	set(value):
		suffix = value
		amount = amount # Triggers the setter of `amount` to update the text
@export_group("Sound")
@export var sound_appear: AudioStream

@onready var _gpos: Vector2 = global_position


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_movement()


func _movement() -> void:
	Sound.play_2d(sound_appear, self)
	
	var tw: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, ^"global_position", _gpos + 64 * Vector2.UP.rotated(get_global_transform().get_rotation()), 0.75)
	tw.tween_interval(0.5)
	tw.tween_property(self, ^"modulate:a", 0, 0.25)
	
	await tw.finished
	queue_free()
