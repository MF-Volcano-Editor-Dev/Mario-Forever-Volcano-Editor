@tool
extends Node2D

var server := RenderingServer


func _ready() -> void:
	server.particles_create()
