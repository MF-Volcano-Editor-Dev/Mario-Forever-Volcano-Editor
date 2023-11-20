extends Component

## Emitted when the item is hit out
signal item_hit_out(hitting_direction: Vector2)

@export_category("Item Component")
@export_group("Sounds", "sound_")
## Sound of the item's appearance
@export var sound_item: AudioStream = preload("res://assets/sounds/appear.wav")


## Plays the [member sound_item] and emits [signal item_hit_out]
func hit_item_out(hitting_direction: Vector2 = Vector2.ZERO) -> void:
	if root is Node2D:
		Sound.play_sound_2d(root, sound_item)
	else:
		Sound.play_sound(root, sound_item)
	
	item_hit_out.emit(hitting_direction)
