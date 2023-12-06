class_name Goal extends Classes.HiddenNode2D

const GoalPole := preload("./goal_pole.gd")

@export_category("Goal Gate")
@export_group("Component Links", "path_")
@export_node_path("Node") var path_goal_character_walk: NodePath = ^"GoalCharacterWalk"
@export_enum("Left: -1", "Right: 1") var direction: int = -1
@export var detection_area: Rect2 = Rect2(Vector2(0, -256), Vector2(640, 256))

var _level_events := Events.get_level_events()

#region == References ==
@onready var goal_pole := $GoalPole as GoalPole
@onready var goal_character_walk := get_node_or_null(path_goal_character_walk) as GoalCharacterWalk
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#endregion


func _ready() -> void:
	_level_events.level_completed.connect(
		func() -> void:
			if !is_instance_valid(animation_player):
				return
			animation_player.pause()
			set_process(false)
	)
	_level_events.level_completion_stopped.connect(
		func() -> void:
			if !is_instance_valid(animation_player):
				return
			animation_player.play()
			set_process(true)
	)

func _process(_delta: float) -> void:
	for i: CharacterEntity2D in CharactersManager2D.get_characters_getter().get_characters():
		if i.is_on_floor() && (global_transform * detection_area).has_point(i.global_position):
			finish(i)
			break


func finish(character_body: Node2D, pole_touched: bool = false) -> void:
	var character := character_body.get_parent() as CharacterEntity2D if !character_body is CharacterEntity2D else character_body
	if !character:
		return
	
	if !pole_touched:
		goal_pole.add_scores.scores = 100
		goal_pole.add_scores.add_scores()
	
	if goal_character_walk:
		goal_character_walk.direction = -direction
		goal_character_walk.add_player_to_walk(character)
	
	_level_events.level_complete()
