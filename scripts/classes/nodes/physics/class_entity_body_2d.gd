@icon("class_entity_body_2d.png")
class_name EntityBody2D extends CharacterBody2D

## Class that extends the functionality of original [CharacterBody2D] with such like [member gravity] and [member motion]
##
## Original [CharacterBody2D] does convenience for us with fast access to velocity operation and slide collision. However, most 
## platform games are filled with bodies that contains gravity, and even in some situations, velocity needs a better 
## usage when it comes to multiple gravity directions. [br]
## This class is designed to solve these problems, which provides a property [member gravity] via which you can directly control
## the strength of the body's gravity. For the thirsty requirement of multiple gravity directions, [member Node2D.global_rotation] 
## of the body is used as the angle of the body's gravity direction, and 0° of [member Node2D.global_rotation] means the body's gravity
## is [b]DOWNWARD[/b]. Also, due to the feature mentioned, another property [member motion] is introduced to set and get 
## the body's [member CharacterBody2D.velocity] with [member Node2D.global_rotation]. If not so, in some cases, it will be hard to
## tell how and in which way the velocity should work.[br]
## [br]
## [b]Notes[/b][br]
## 1. [member Node2D.global_rotation] is used for assignment of the body's gravity direction(and also its [member CharacterBody2D.up_direction]), 
## so if you expect to rotate the body, please use [method rotate_body] instead of directly changing the property!

## Emitted when the body collides with a wall
signal collided_wall
## Emitted when the body collides with a ceiling
signal collided_ceiling
## Emitted when the body collides with a floor
signal collided_floor

## Easier accessor to [member CharacterBody2D.velocity], affecting this property (velocity) with [member Node2D.global_rotation]
@export var motion: Vector2:
	get: return velocity.rotated(-global_rotation)
	set(value): velocity = value.rotated(global_rotation)
## Gravity acceleration of the body
@export_range(-1, 1, 0.001, "or_less", "or_greater", "hide_slider", "suffix: px/s²") var gravity: float
@export var gravity_direction: Vector2 = Vector2.DOWN:
	set(value): gravity_direction = value.normalized()
## Maximum of [member motion].y under the action of gravity. This property is POSITIVE ONLY.
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix: px/s") var max_falling_speed: float = 1500

var _velocity: Vector2

var _temp_up_direction: Vector2
var _temp_up_direction_real: Vector2:
	get = get_real_up_direction, 
	set = set_real_up_direction


func move(delta: float) -> void:
	_velocity = velocity
	_temp_up_direction = up_direction
	_temp_up_direction_real = up_direction

	if is_on_floor() != floor_stop_on_slope:
		velocity = ExtensiveMath.Vector2D.projection_limit(velocity + gravity_direction * gravity * delta, gravity_direction, max_falling_speed)
	
	move_and_slide()
	if !floor_constant_speed:
		velocity = get_real_velocity()
	
	up_direction = _temp_up_direction
	
	if is_on_wall():
		collided_wall.emit()
	if is_on_ceiling():
		collided_ceiling.emit()
	if is_on_floor():
		collided_floor.emit()


func jump(jumping_speed: float) -> void: 
	motion.y = -abs(jumping_speed)


func accelerate(_to: Vector2, _acceleration: float, _delta: float) -> void: pass
func accelerate_x(_to: float, _acceleration: float, _delta: float) -> void: pass
func accelerate_y(_to: float, _acceleration: float, _delta: float) -> void: pass
func turn_x() -> void: pass
func turn_y() -> void: pass


func set_real_up_direction(value: Vector2) -> void:
	up_direction = value.rotated(global_rotation)
	_temp_up_direction_real = up_direction


func get_real_up_direction() -> Vector2:
	return _temp_up_direction_real

