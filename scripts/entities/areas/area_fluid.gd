class_name AreaFluid extends Area2D

## [AreaFluid] is an field in which characters is able to swim.
##
## [b]Note:[/b] This node is only avaiable for [Character].
## For modification on general [EntityBody2D]s, see [member Area2D.gravity_space_override]

@export_group("For Character", "character_")
## Scales for properties, going to be modified, of a characters that.[br]
## [br]
## [b]Note:[/b] The keys are of [NodePath] or [String] type while the values belong to one of the numeric types.[br]
## [br]
## [b]Warning:[/b] Only numberic types are supported; otherwise, an error would be thrown!
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:x") var character_max_falling_speed_scale: float = 1.0
@export_group("Spray")
@export var spray: PackedScene

var _bodies_count: int
var _prev_bodies_count: int
var _characters: Array[Character]


func _init() -> void:
	process_physics_priority = -128 # Needs this line to make sure the _property_update() will be called before all nodes in the current scene

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	_property_update() # This will be called BEFORE all nodes get the virtual method called
	_property_revert.call_deferred() # This will be called AFTER all nodes get the virtual method called


#region == Updating and Reverting Data ==
func _property_update() -> void:
	for i in _characters:
		i.max_falling_speed *= character_max_falling_speed_scale

func _property_revert() -> void:
	for i in _characters:
		i.max_falling_speed /= character_max_falling_speed_scale
#endregion


func _bodies_count_changed() -> bool:
	# Ready requires 5 frames
	if get_tree().get_frame() > 5 && _prev_bodies_count != _bodies_count:
		_prev_bodies_count = _bodies_count
		return true
	
	_prev_bodies_count = _bodies_count
	return false

func _spray(body: Node2D) -> void:
	if !spray:
		return
	if !body is PhysicsBody2D:
		return
	
	var e: Node2D = spray.instantiate()
	e.global_transform = body.global_transform
	
	add_sibling.call_deferred(e)


#region == Area Detections ==
func _on_body_entered(body: Node2D) -> void:
	_bodies_count += 1
	
	if body is Character && !body in _characters:
		_characters.append(body)
	
	await get_tree().physics_frame
	if _bodies_count_changed():
		_spray(body)

func _on_body_exited(body: Node2D) -> void:
	_bodies_count -= 1
	
	if body is Mario && body in _characters:
		_characters.erase(body)
	
	await get_tree().physics_frame
	if _bodies_count_changed() && is_instance_valid(body):
		_spray(body)
#endregion
