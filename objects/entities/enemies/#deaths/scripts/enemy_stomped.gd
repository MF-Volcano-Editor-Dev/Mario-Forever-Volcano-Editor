extends EntityBody2D

## Emitted when it's time to disappear
signal disappeared

@export_category("Disappear")
@export_range(0, 20, 0.001, "suffix:s") var disappear_delay: float = 2


func _ready() -> void:
	if disappear_delay > 0:
		await get_tree().create_timer(disappear_delay, false).timeout
		
		var tw: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		tw.tween_property(self, "modulate:a", 0, 0.25)
		
		await tw.finished
		
		disappeared.emit()


func _physics_process(_delta: float) -> void:
	move_and_slide()
