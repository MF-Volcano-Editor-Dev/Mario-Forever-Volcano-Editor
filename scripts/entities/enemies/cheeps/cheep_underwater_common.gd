extends Node2D

signal cheep_out_of_fluid ## Emitted when the cheep is out of specific fluid. See [member fluid_group].
signal cheep_collided_wall ## Emitted when the cheep collides with wall.

@export_category("Cheep Swimming")
@export var fluid_group: StringName = &"water"
@export var facing_character: bool = true
@export_group("References")
@export_node_path("ShapeCast2D") var collider_path: NodePath = ^"Collider"
@export_node_path("Area2D") var effect_box_path: NodePath = ^"EffectBox"
@export_node_path("Timer") var timer_interval_path: NodePath = ^"TimerInterval"
@export_group("Physics")
@export_enum("Linear", "Up Down", "Homing") var swimming_mode: int:
	set(value):
		swimming_mode = value
		
		if !is_node_ready():
			await ready
		
		if swimming_mode == 1:
			_timer_interval.start(swimming_up_down_interval)
		elif swimming_mode == 2:
			_timer_interval.start(homing_interval)
@export var collidable: bool
@export_subgroup("Up Down & Linear", "swimming_")
@export var swimming_speed: Vector2 = Vector2(50, 0)
@export_range(0, 180, 0.001, "degrees") var swimming_up_down_central_angle: float = 22.5
@export_range(0, 20, 0.001, "suffix:s") var swimming_up_down_interval: float = 1
@export_subgroup("Homing", "homing_")
@export_range(0, 60, 0.001, "suffix:s") var homing_interval: float = 1

var velocity: Vector2

var _local_velocity: Vector2
var _delayed: int = 8
var _normal: Vector2
var _nearest_player: Character

@onready var _collider: ShapeCast2D = get_node(collider_path)
@onready var _effect_box: Area2D = get_node(effect_box_path)
@onready var _timer_interval: Timer = get_node(timer_interval_path)


func _ready() -> void:
	swimming_mode = swimming_mode # Triggers setter to initialize the swimming mode
	
	_timer_interval.timeout.connect(_on_interval)
	
	if facing_character:
		_nearest_player = Character.Getter.get_nearest(get_tree(), global_position)
		if _nearest_player:
			var dir := Transform2DAlgo.get_direction_to_regardless_transform(global_position, _nearest_player.global_position, global_transform)
			velocity = dir * swimming_speed.rotated(global_rotation)

func _process(delta: float) -> void:
	if _collider.is_colliding():
		for i in _collider.get_collision_count():
			_normal = _collider.get_collision_normal(i) # Get normal for turning back
			
			var col := _collider.get_collider(i)
			if collidable && (!col is AreaFluid || (col is AreaFluid && !col.is_in_group(fluid_group))):
				cheep_collided_wall.emit()
	elif _normal.is_normalized(): # Turn back to prevent from going out of water
		collide_wall() 
	
	global_position += velocity * delta
	_local_velocity = velocity.rotated(-global_rotation)
	_collider.position = 16 * _local_velocity.normalized()
	
	set_meta(&"facing", signf(_local_velocity.x))
	
	if _delayed > 0:
		_delayed -= 1 # To prevent from mistaken detect as being out of water
		return
	
	# If the cheep is indeed out of water, the notify that the fish is out of water currently
	# And the signal should be connected to forced_kill() of EnemyKillingProcess
	var is_in_fluid: bool = false
	for i in _effect_box.get_overlapping_areas():
		if i.is_in_group(fluid_group):
			is_in_fluid = true
			break
	if !is_in_fluid:
		cheep_out_of_fluid.emit()
		return


func collide_wall() -> void:
	if !_normal.is_normalized():
		return
	velocity = velocity.bounce(_normal)


func _on_interval() -> void:
	match swimming_mode:
		1: # Up Down
			velocity = signf(_local_velocity.x) * swimming_speed.rotated(global_rotation + deg_to_rad(randf_range(-swimming_up_down_central_angle, swimming_mode) / 2))
		2: # Homing
			if !_nearest_player:
				velocity = Vector2.ZERO
				return
			velocity = swimming_speed.rotated(global_position.angle_to_point(_nearest_player.global_position))
