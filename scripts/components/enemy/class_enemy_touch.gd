@tool
@icon("res://icons/enemy_touch.svg")
class_name EnemyTouch extends Component

## Component used for [Area2D] to provide collision interaction with [Character]. It makes the character hurt as if the character got hit by an enemy.
##
## This component allows an [Area2D] to react as a hitbox of an enemy. When a [Character] collides with the area, the character will get hurt ([method Character.hurt] will be called).

signal on_touched_by_character(character: Character) ## Emitted when a character touches the [member Component.root] ([Area2D]).
signal character_left(character: Character) ## Emitted when a character leaves from the area.

## If [code]true[/code], the character won't get hurt if he/she gets hit by the area.[br]
## [br]
## [b]Note:[/b] For [EnemyStompable], if [code]true[/code], the character won't get hurt even if he/she fails stomping.
@export var character_damagible: bool = true

var _characters_detected: Array[Character] # Characters detected


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if !root is Area2D:
		return
	
	var area := root as Area2D
	area.body_entered.connect(_on_character_touched)
	area.body_exited.connect(_on_character_left)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _characters_detected.is_empty():
		return
	
	for i in _characters_detected:
		_character_touched(i)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if !get_root() is Area2D:
		warnings.append("The component works only when the \"root\" is an Area2D.")
	
	return warnings


## [code]virtual[/code] Called when a character collides the [member Component.root] ([Area2D]).
func _character_touched(character: Character) -> void:
	if !is_instance_valid(character):
		return
	character.hurt()


#region == Character entering/exiting the area ==
func _on_character_touched(body: Node2D) -> void:
	if !body is Character:
		return
	if body in _characters_detected:
		return
	
	var chara := body as Character # Character
	
	_characters_detected.append(chara)
	
	on_touched_by_character.emit(chara)

func _on_character_left(body: Node2D) -> void:
	if !body is Character:
		return
	if !body in _characters_detected:
		return
	
	var chara := body as Character # Character
	
	_characters_detected.erase(chara)
	
	character_left.emit(chara)
#endregion
