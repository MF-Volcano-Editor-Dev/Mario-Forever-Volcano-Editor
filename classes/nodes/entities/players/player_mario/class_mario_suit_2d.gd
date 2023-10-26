class_name MarioSuit2D extends Node2D

## A kind of component only used for [Mario2D] to provide
## fast-modifible module for the character

# #mario_suit_owned

@export_group("General")
## [member EntityBody2D.character_id] of the character [br]
## [b]Note:[/b] This is used for suit registeration, and MUST keep the same
## as one in the character you are looking for
@export var character_id: StringName = &"mario"
## Id of the suit, also used in [member Mario2D][br]
## [b]Note:[/b] This is used for suit registeration, see [member Mario2D.suit_id]
@export var suit_id: StringName = &"small"
## The [member suit_id] of the suit when the player gets hurt [br]
## If this is empty, the character will die when getting damaged
@export var down_suit_id: StringName = &""
## Features of the suit, effects some of the results of [member behavior][br]
## Use "," to separate each features and use "_" to take the place if space
@export var suit_features: String = ""

## [Sprite2D] of the suit
@onready var sprite: Sprite2D = $Sprite2D
## [AnimationPlayer] of the suit to control displaying of [member sprite]
@onready var animation: AnimationPlayer = $AnimationPlayer
## [Component] of the suit that process core codes
@onready var behavior: Node = $Behavior


func _ready() -> void:
	for i: Node in get_children():
		if i.is_in_group(&"#mario_suit_owned"):
			continue
		i.reparent.call_deferred(get_parent())


#region Animations
## Plays appearing animation of the suit
func appear(duration: float = 1.0) -> void:
	animation.play(&"appear")
	await get_tree().create_timer(duration, false).timeout
	animation.play(&"RESET")
#endregion


#region Setters & Getters
## Returns the [Mario2D] linking to this suit
func get_player() -> Mario2D:
	var player: Mario2D = get_parent()
	return player if is_instance_valid(player) else null
#endregion
