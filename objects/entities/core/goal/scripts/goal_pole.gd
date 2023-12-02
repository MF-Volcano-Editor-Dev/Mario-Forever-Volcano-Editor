extends EntityBody2D

const SCORES: PackedInt32Array = [200, 500, 1000, 2000, 5000, 10000]

var _direction: int

@onready var goal := get_parent() as Goal
@onready var detector: Area2D = $Area2D
@onready var add_scores: AddScores = $AddScores


func _ready() -> void:
	set_physics_process(false)
	detector.area_entered.connect(_on_character_area_touched)

func _physics_process(delta: float) -> void:
	move_and_slide()
	rotate(_direction * PI * 4.16667 * delta)



func _on_character_area_touched(area: Area2D) -> void:
	var character := area.get_parent() as CharacterEntity2D
	if !character:
		return
	
	var segment := goal.animation_player.current_animation_length / float(SCORES.size())
	var bottom := 0.0
	for i in SCORES.size():
		if goal.animation_player.current_animation_position >= bottom && goal.animation_player.current_animation_position < bottom + segment:
			add_scores.scores = SCORES[i]
			break
		bottom += segment
	
	_direction = goal.direction
	global_velocity = Vector2(_direction, -1).normalized().rotated(randf_range(-PI/12, PI/12) + global_rotation) * randf_range(150, 300)
	set_physics_process(true)
	
	detector.queue_free()
	goal.finish(area, true)
