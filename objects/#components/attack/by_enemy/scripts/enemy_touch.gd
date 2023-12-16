@icon("res://icons/enemy_touch.svg")
class_name EnemyTouch extends AreaDetectingComponent

signal hurt_character ## Emitted when the enemy hurts the character
signal touched_character_friendly(character: CharacterEntity2D) ## Emitted when the enemy touches the character harmlessly

@export_category("Enemy Touch")
## If [code]true[/code], the enemy will not hurt the character
@export var harmless: bool
## Tags when the body hurts the character
@export var hurt_tags: TagsObject

var _entity_areas: Array[Area2D]

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
	for i: Area2D in _entity_areas:
		_touches_entity_area(i)


#region == Touching a character ==
func _on_character_in_area(area: Area2D, in_or_out: bool) -> void:
	if disabled || is_area_ignored(area) || !area.is_in_group(&"%%enemy_touchable"):
		set_process(false)
		return
	if in_or_out:
		if !area in _entity_areas:
			_entity_areas.append(area)
	elif area in _entity_areas:
		_entity_areas.erase(area)
	set_process(!_entity_areas.is_empty())

## Handles the behavior of the [param character] touching the enemy.[br]
## [b]Note:[/b] It's recommended to override this method in child classes if you want to customize the behavior
## of manipulation on this behavior.
func _touches_entity_area(entity_area: Area2D) -> void:
	var character := entity_area.get_parent() as CharacterEntity2D
	if !character:
		return
	if harmless:
		touched_character_friendly.emit(character)
	else:
		hurt_character.emit()
		character.damaged(hurt_tags)
#endregion
