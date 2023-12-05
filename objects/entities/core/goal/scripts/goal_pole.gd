extends EntityBody2D

const SCORES: PackedInt32Array = [200, 500, 1000, 2000, 5000, 10000]

var _direction: int

#region == References ==
@onready var goal := get_parent() as Goal
@onready var detector: Area2D = $Area2D
@onready var add_scores: AddScores = $AddScores
#endregion
@onready var detector_collision_mask: int = detector.collision_mask


func _ready() -> void:
	set_physics_process(false) # Disables movement at first
	detector.area_entered.connect(_on_character_area_touched)
	Events.signals.level_completed.connect(
		func() -> void:
			if !is_instance_valid(detector):
				return
			detector.collision_mask = 0 # Cancels collision detection of the detector on the completion of current level
	)
	Events.signals.level_completion_stopped.connect(
		func() -> void:
			if !is_instance_valid(detector):
				return
			detector.collision_mask = detector_collision_mask # Restores collision detection of the detector if the completion is stopped
	)

func _physics_process(delta: float) -> void:
	move_and_slide()
	rotate(_direction * PI * 4.16667 * delta)


func _on_character_area_touched(area: Area2D) -> void:
	var character := area.get_parent() as CharacterEntity2D
	if !character:
		return
	
	if is_instance_valid(goal.animation_player):
		var segment := goal.animation_player.current_animation_length / float(SCORES.size())
		var bottom := 0.0
		for i in SCORES.size():
			if goal.animation_player.current_animation_position >= bottom && goal.animation_player.current_animation_position < bottom + segment:
				add_scores.scores = SCORES[i]
				add_scores.add_scores()
				break
			bottom += segment
	
	_direction = goal.direction
	global_velocity = Vector2(_direction, -1).normalized().rotated(randf_range(-PI/12, PI/12) + global_rotation) * randf_range(150, 300)
	set_physics_process(true)
	
	detector.queue_free() # Destroy the detector
	if is_instance_valid(goal.animation_player):
		goal.animation_player.queue_free() # Removes the goal's animation player to make the pole behaves guardedly
	
	goal.finish(area, true)
