extends Area2D

var _player: Mario2D
var _removed_crouching: bool


@onready var suit: MarioSuit2D = get_parent()


func _ready() -> void:
	_player = suit.get_player()
	
	_player.state_machine.state_removed.connect(
		func(state: StringName) -> void:
			if state == &"crouching":
				_removed_crouching = true
				
				for i in 10:
					await get_tree().process_frame
				
				_removed_crouching = false
	)


func _process(_delta: float) -> void:
	if _removed_crouching && !get_overlapping_bodies().is_empty():
		_removed_crouching = false
		
		for i in 2:
			await get_tree().process_frame
		
		if get_overlapping_bodies().is_empty():
			return
		
		if !"small" in suit.suit_features:
			_player.suit_id = &"small"
			suit.behavior.sound.play_sound(suit.sound_hurt, get_tree().current_scene)
