class_name AreaFluid2D extends Area2D

@export_category("Fluid")
## ID of the fluid
@export var fluid_id: StringName
@export_group("Entity Physics")
@export_subgroup("Charater", "character_")
## If [code]true[/code], the character in the fluid is swimmable[br]
## [code]Note:[/code] This is implemented only when the character is reactable to this property,
## Otherwise, it's no any use.
@export var character_swimmable: bool
@export_subgroup("")
## Modifies [member EntityBody2D.max_speed_scale], and will return to 1.0 if the body leaves from the fluid
@export_range(0, 20, 0.001, "suffix:x") var max_speed_scale: float = 1
## Modifies [member EntityBody2D.max_falling_speed_scale], and will return to 1.0 if the body leaves from the fluid
@export_range(0, 20, 0.001, "suffix:x") var max_falling_speed_scale: float = 1
@export_group("Fluid Spray")
## Spray effect generated when a body enters and exits from the fluid
@export var spray: PackedScene

var _delayed: bool


func _ready() -> void:
	# Then connect the spray
	body_entered.connect(_fluid_trigger.bind(true))
	body_exited.connect(_fluid_trigger.bind(false))
	
	# Await for one physics frame to stop sprays from being generated
	# when physics bodies are initially overlapped with the fluid
	await get_tree().physics_frame
	_delayed = true


## Create [member spray] effect on a body with [param transform] preset
func create_spray(body: Node2D, global_trans: Transform2D) -> void:
	if !spray:
		return
	
	var s := spray.instantiate()
	if !s is Node2D:
		s.queue_free()
		return
	
	s = s as Node2D
	s.global_transform = global_trans
	body.add_sibling.call_deferred(s)


func _fluid_trigger(body: Node2D, is_entering: bool) -> void:
	# Spray creation
	create_spray(body, Transform2D(0, body.global_scale, body.global_skew, body.global_position))
	
	# Stop the sprays from being created when the bodies are initialized
	# within the fluid at the very beginning of the game
	if !_delayed:
		return
	
	if body is EntityBody2D:
		if is_entering:
			body.max_falling_speed_scale = max_falling_speed_scale
			body.max_speed_scale = max_speed_scale
		else:
			body.max_falling_speed_scale = 1.0
			body.max_speed_scale = 1.0

