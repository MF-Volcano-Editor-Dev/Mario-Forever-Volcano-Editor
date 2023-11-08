class_name MarioSuit2D extends Node2D

## A kind of component only used for [Mario2D] to provide
## fast-modifible module for the character

# #mario_shapes

@export_group("General")
## Id of the suit, also used in [member Mario2D][br]
## [b]Note:[/b] This is used for suit registeration, see [member Mario2D.suit_id]
@export var suit_id: StringName = &"small"
## The [member suit_id] of the suit when the player gets hurt [br]
## If this is empty, the character will die when getting damaged
@export var down_suit_id: StringName = &""
## Features of the suit, effects some of the results of [member behavior][br]
## Use "," to separate each features and use "_" to take the place if space
@export var suit_features: String = ""
@export_group("Shape Lib")
## Name of the suit's shape lib
@export var shape_lib_name: StringName
## [AnimationLibrary] that the [member shape_lib_name] refers to
@export var shape_lib: AnimationLibrary
@export_group("Death")
## Death of the mario in such suit
@export var death: PackedScene = preload("res://objects/entities/players/mario/#death/mario_death.tscn")
@export_group("Sounds")
## Sound of taking damage
@export var sound_hurt: AudioStream = preload("res://assets/sounds/power_down.wav")
## Sound of death
@export var sound_death: AudioStream = preload("res://assets/sounds/death.ogg")

## [Sprite2D] of the suit
@onready var sprite: Sprite2D = $Sprite2D
## [AnimationPlayer] of the suit to control displaying of [member sprite]
@onready var animation: AnimationPlayer = $AnimationPlayer
## [Component] of the suit that process core codes
@onready var behavior: Node = $Behavior
## [Sound2D] of the suit
@onready var sound: Sound2D = $Sound2D


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
	var pl := get_parent() as Mario2D
	return pl if is_instance_valid(pl) else null


## Returns [code]true[/code] if the suit is current
func is_current() -> bool:
	var pl := get_parent() as Mario2D
	return pl && pl.suit_id == suit_id
#endregion
