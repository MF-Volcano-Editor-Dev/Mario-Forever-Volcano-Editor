class_name AreaFluid extends Area2D

@export_group("For Character", "character_")
## Properties of a character, which is going to be modified.[br]
## [br]
## [b]WARNING:[/b] Only numberic types are supported; otherwise, an error would be thrown!
@export var character_overriding_scales: Dictionary = {
	max_falling_speed = 0.3
}
@export_group("Spray")
@export var spray_emitter: PackedScene

var _characters: Array[Character]

func _init() -> void:
	process_physics_priority = -128 # Needs this line to make sure the _property_update() will be called before all nodes in the current scene

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	_property_update() # This will be called BEFORE all nodes get the virtual method called
	_property_restore.call_deferred() # This will be called AFTER all nodes get the virtual method called


func _property_update() -> void:
	for i in _characters:
		for j in character_overriding_scales:
			i.set_indexed(j, i.get_indexed(j) * character_overriding_scales[j])

func _property_restore() -> void:
	for i in _characters:
		for j in character_overriding_scales:
			i.set_indexed(j, i.get_indexed(j) / character_overriding_scales[j])


func _on_body_entered(body: Node2D) -> void:
	if body is Character && !body in _characters:
		_characters.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body is Mario && body in _characters:
		_characters.erase(body)
