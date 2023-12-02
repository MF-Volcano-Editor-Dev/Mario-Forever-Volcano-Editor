class_name Goal extends Classes.HiddenNode2D

const GoalPole := preload("./goal_pole.gd")

@export_category("Goal Gate")
@export_group("Component Links", "path_")
@export_node_path("Node") var path_goal_character_walk: NodePath = ^"GoalCharacterWalk"
@export_enum("Left: -1", "Right: 1") var direction: int = -1
@export_enum("Rectangle", "Border") var detection_mode: int = 1:
	set(value):
		detection_mode = value
		await Process.await_current_scene_readiness(get_tree())
		goal_detector_box.set_deferred(&"shape", detection_mode != 0)
		goal_detector_border.set_deferred(&"shape", detection_mode != 1)

#region == References ==
@onready var goal_pole := $GoalPole as GoalPole
@onready var goal_detector: Area2D = $Area2D
@onready var goal_detector_box: CollisionShape2D = $Area2D/Box
@onready var goal_detector_border: CollisionShape2D = $Area2D/Border
@onready var goal_character_walk := get_node_or_null(path_goal_character_walk) as GoalCharacterWalk
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#endregion


func _ready() -> void:
	goal_detector.area_entered.connect(finish)


func finish(character_body: Area2D, pole_touched: bool = false) -> void:
	var character := character_body.get_parent() as CharacterEntity2D
	if !character:
		return
	
	animation_player.stop(true)
	if is_instance_valid(goal_detector_box): # CAUTION: This MUST check the validity since the pole will call this, too
		goal_detector_box.queue_free()
	if is_instance_valid(goal_detector_border): # The same
		goal_detector_border.queue_free()
	
	if !pole_touched:
		goal_pole.add_scores.scores = 100
		goal_pole.add_scores.add_scores()
	
	if goal_character_walk:
		goal_character_walk.direction = -direction
		goal_character_walk.add_player_to_walk(character)
	
	EventsManager.level_finish()
