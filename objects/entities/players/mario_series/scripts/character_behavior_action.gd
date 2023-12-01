class_name CharacterAction2D extends Component

@export_category("Character Behavior Action")
## Name of the action
@export var action_name: StringName

@onready var behavior := get_parent() as CharacterBehavior2D
@onready var power := behavior.get_parent() as CharacterPower2D
@onready var character := power.get_parent() as CharacterEntity2D
