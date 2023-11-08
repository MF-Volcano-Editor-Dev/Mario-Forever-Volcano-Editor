extends Node

## Emitted when [method stomped_process] is done
signal stomped_process_done

## Emitted when [killed_process] is done
signal killed_process_done

@export_category("Goomba Death Process")
@export_group("Killed")
@export var goomba_stomped: PackedScene = preload("../goomba_stomped.tscn")
@export var goomba_killed: PackedScene = preload("../goomba_death.tscn")

@onready var goomba: EntityBody2D = get_parent()
@onready var body: Area2D = $"../Area2D"
@onready var animated_sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var sound: Sound2D = $"../Sound2D"


func stomped_process() -> void:
	var stp := goomba_stomped.instantiate() as Node2D
	if !stp:
		stp.queue_free()
		return
	
	stp.global_transform = goomba.global_transform
	goomba.add_sibling.call_deferred(stp)
	
	stomped_process_done.emit()


func killed_process() -> void:
	if !goomba_killed:
		return
	
	var gk := goomba_killed.instantiate() as Node2D
	if !gk:
		gk.queue_free()
		return
	
	gk.global_transform = goomba.global_transform
	gk.gravity_direction = goomba.get_gravity_vector().normalized()
	gk.direction = int(signf(goomba.speed))
	goomba.add_sibling(gk)
	
	killed_process_done.emit()
