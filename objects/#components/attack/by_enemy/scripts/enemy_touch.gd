@icon("res://icons/enemy_touch.svg")
class_name EnemyTouch extends Component

signal hurt_character ## Emitted when the enemy hurts the character

@export_category("Enemy Touch")
## Tags when the body hurts the character
@export var hurt_tags: TagsObject

var _characters: Array[CharacterEntity2D]

@onready var _area := get_root() as Area2D


func _init() -> void:
	set_physics_process(false)

func _ready() -> void:
	if !_area:
		return
	_area.area_entered.connect(_on_character_in_area.bind(true))
	_area.area_exited.connect(_on_character_in_area.bind(false))

func _process(_delta: float) -> void:
	if disabled:
		return
	for i: CharacterEntity2D in _characters:
		_touches_character(i)


#region == Touching a character ==
func _on_character_in_area(area: Area2D, in_or_out: bool) -> void:
	if disabled:
		set_process(false)
		return
	
	var character := area.get_parent() as CharacterEntity2D
	if !character:
		return
	if in_or_out && !character in _characters:
		_characters.append(character)
	elif !in_or_out && character in _characters:
		_characters.erase(character)
	set_process(!_characters.is_empty())

## Handles the behavior of the [param character] touching the enemy.[br]
## [b]Note:[/b] It's recommended to override this method in child classes if you want to customize the behavior
## of manipulation on this behavior.
func _touches_character(character: CharacterEntity2D) -> void:
	character.damaged(hurt_tags)
#endregion
