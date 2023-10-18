class_name MarioSuit2D extends Node2D

@export_group("General")
@export var character_id: StringName = &"mario"
@export var suit_id: StringName = &"small"
@export var down_suit_id: StringName = &""
@export_group("Direct-manage Nodes")
@export var direct_manage_nodes: Array[Node]
@export_group("Collision Boxes")
@export var collision_boxes_normal: Array[CollisionShape2D]
@export var collision_boxes_crouch: Array[CollisionShape2D]
@export_group("Suit Sounds", "sound_")
@export var sound_hurt: AudioStream = preload("res://assets/sounds/power_down.wav")
@export var sound_death: AudioStream = preload("res://assets/sounds/player_death.ogg")

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var body: Area2D = $Area2D
@onready var sound: Sound2D = $Sound2D

var _player: Mario2D:
	get = get_player


func deploy(on: Mario2D) -> void:
	if !is_instance_valid(on):
		return
	elif !on.is_node_ready():
		await on.ready
	
	for i: Node in direct_manage_nodes:
		i.reparent.call_deferred(on, false)
	
	_player = on
	_player.add_child.call_deferred(self)


##regionbegin Animations
func appear(duration: float = 1.0) -> void:
	animation.play(&"Mario/appear")
	await get_tree().create_timer(duration, false).timeout
	animation.play(&"Mario/RESET")


func crouch_collision_shapes(is_crouching: bool) -> void:
	if collision_boxes_crouch.is_empty():
		return
	for i: CollisionShape2D in collision_boxes_normal:
		i.set_deferred(&"disabled", is_crouching)
	for j: CollisionShape2D in collision_boxes_crouch:
		j.set_deferred(&"disabled", !is_crouching)
##endregion


##regionbegin Setters & Getters
func get_player() -> Mario2D:
	return _player if is_instance_valid(_player) else null
##endregion
