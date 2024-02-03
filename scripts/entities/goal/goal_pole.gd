extends Area2D

const _GOAL: Script = preload("./goal.gd")

@export_category("Goal Pole")
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:x") var gravity_scale: float = 0.2
@export_range(-18000, 18000, 0.001, "suffix:°/s") var rotation_speed: float = 500

var _dir: int
var _velocity: Vector2
var _gravity: Vector2 = ProjectSettings.get_setting("physics/2d/default_gravity_vector", Vector2.DOWN) * ProjectSettings.get_setting("physics/2d/default_gravity", 980.0) * gravity_scale

@onready var _trans: Transform2D = transform
@onready var _index: int = get_index()

@onready var _goal: _GOAL = get_parent()


func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	
	area_entered.connect(
		func(area: Area2D) -> void:
			_gravity = area.gravity_direction * area.gravity * gravity_scale
	)
	
	body_entered.connect(
		func(body: Node2D) -> void:
			if _goal._has_completed:
				return
			if !Character.Checker.is_character(body):
				return
			
			set_process(true)
			
			_dir = _goal.facing
			_goal._hit_pole = true
			_goal.complete_level(body)
			
			reparent.call_deferred(_goal.get_parent())
	, CONNECT_ONE_SHOT)


func _process(delta: float) -> void:
	_velocity += _gravity * delta
	global_position += _velocity * delta
	rotate(deg_to_rad(rotation_speed) * _dir * delta)


## Restores the pole to where it was generated.
func restore_pos() -> void:
	transform = _trans
	(func() -> void:
		reparent(_goal)
		_goal.move_child(self, _index)
	).call_deferred()
	
