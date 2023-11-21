extends Component

## Emitted when the powerup is got by a character
signal powerup_got

@export_category("Powerup")
## Defines which level is the baseline to make the character
## powered to the suit with [member line_suit_id], and if the level is lower than this value,
## the character will turn into the suit with id [member beneth_suit_id]
@export_range(-10, 10, 1) var baseline_suit_level: int
## ID of the suit that the character's current suit level is lower than [baseline_suit_level]
@export var beneth_suit_id: StringName = &"big"
## ID of the suit that the character's current suit level is greater or equal than [baseline_suit_level]
@export var line_suit_id: StringName = &"big"
@export_group("Sounds", "sound_")
@export var sound_item: AudioStream = preload("res://assets/sounds/power_up.wav")


func _ready() -> void:
	super()
	
	if !root is Area2D:
		return
	
	root.area_entered.connect(_on_player_got_powerup)


func _on_player_got_powerup(area: Area2D) -> void:
	var pl := area.get_parent() as Mario2D
	if !pl:
		return
	
	var suit := pl.get_suit()
	if !suit:
		return
	
	Sound.play_sound_2d(root, sound_item)
	
	if suit.suit_level < baseline_suit_level && !beneth_suit_id.is_empty() && pl.suit_id != beneth_suit_id:
		pl.suit_id = beneth_suit_id
		
	elif suit.suit_level == baseline_suit_level && !line_suit_id.is_empty() && pl.suit_id != line_suit_id:
		pl.suit_id = line_suit_id
	
	powerup_got.emit()
