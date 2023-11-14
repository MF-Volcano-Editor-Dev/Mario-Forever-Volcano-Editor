extends AnimatableBody2D

## Abstract class that provides basic properties and functions for bonus blocks
##
##

## Emitted when the block gets hit from the bottom
signal got_hit_bottom(by_area: Node2D)

## Emitted when the block gets hit from the side
signal got_hit_side(by_area: Node2D)

## Emitted when the block gets hit from the top
signal got_hit_top(by_area: Node2D)

@export_category("Hittable Block")
## Decides the collision direction, affected by [member Node2D.global_rotation]
@export var up_direction: Vector2 = Vector2.UP:
	set(value):
		up_direction = value.normalized()
@export_group("Detector")
## Received types from [constant Classes.BlockHitter]
@export var hitter_types: Array[StringName]
@export_group("Visibility")
## If [code]true[/code], the node will not be able to collide with any
## body, nor can the body be seen
@export var transparent: bool:
	set(value):
		transparent = value
		if !transparent:
			return
		
		if !is_node_ready():
			await ready
		
		if sprite:
			sprite.visible = false
		collision_layer = 0
		collision_mask = 0
@export_group("Sounds", "sound_")
@export var sound_hit: AudioStream

@onready var sprite: Node2D = Process.get_child_in_group(self, "#sprite") as Node2D
@onready var sprite_pos: Vector2 = sprite.position if sprite else Vector2.ZERO
@onready var visiblility: bool = sprite.visible if sprite else true
@onready var col_layer: int = collision_layer
@onready var col_mask: int = collision_mask


## Called by [constant Classes.BlockHitter]
func block_got_hit(area: Area2D, by: Classes.BlockHitter, direction: Vector2 = Vector2.ZERO) -> void:
	if !area || !by:
		return
	
	# Filter out-of-range hitters
	var in_target: int = 0
	for i: StringName in by.hitter_targets:
		if !i in hitter_types:
			continue
		in_target += 1
	if !in_target:
		return
	
	Sound.play_sound_2d(self, sound_hit)
	
	var dot := get_hitting_direction_dot_up(area) if !direction else direction.dot(up_direction.rotated(global_rotation))
	var diag := cos(PI/4)
	
	if dot > diag:
		got_hit_bottom.emit(area)
	elif dot <= diag && dot >= -diag:
		got_hit_side.emit(area)
	else:
		got_hit_top.emit(area)


## Restore the block from being transparent
func restore_from_transparency() -> void:
	if !transparent:
		return
	transparent = false
	
	if sprite:
		sprite.visible = visiblility
	collision_layer = col_layer
	collision_mask = col_mask


## Hitting animation
func hit_animation(by_area: Area2D) -> void:
	const PIXELS := 8.0
	
	var dot := get_hitting_direction_dot_up(by_area)
	var to := Vector2.ZERO
	var diag := cos(PI/4)
	
	if dot > diag:
		to = Vector2.UP * PIXELS
	elif dot <= diag && dot >= -diag:
		var dot_side := get_area_hitting_direction(by_area).dot(-up_direction.orthogonal())
		if dot_side > 0:
			to = Vector2.RIGHT * PIXELS
		elif dot_side < 0:
			to = Vector2.LEFT * PIXELS
	else:
		to = Vector2.DOWN * PIXELS
	
	if sprite:
		var tw := create_tween().set_trans(Tween.TRANS_SINE)
		tw.tween_property(sprite, "position", sprite_pos + to, 0.1)
		tw.tween_property(sprite, "position", sprite_pos, 0.1)


#region Getters
func get_area_hitting_direction(by_area: Node2D) -> Vector2:
	return (global_position - by_area.global_position).normalized()


func get_hitting_direction_dot_up(by_area: Node2D) -> float:
	return get_area_hitting_direction(by_area).dot(up_direction.rotated(global_rotation))
#endregion
