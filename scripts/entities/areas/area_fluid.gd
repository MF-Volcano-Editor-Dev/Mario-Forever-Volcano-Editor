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
@export_group("State to Attach")
## When a body enters the fluid, the body will be given the state.
## And when it leaves from the fluid, the state will be removed.
@export var state_for_body: StringName

var _characters: Array[Character]


func _init() -> void:
	process_physics_priority = -128 # Needs this line to make sure the _property_update() will be called before all nodes in the current scene

func _ready() -> void:
	body_entered.connect(func(body: Node2D) -> void:
		if body is Character:
			_characters.append(body)
		body.add_to_group(&"state_" + state_for_body)
	)
	body_exited.connect(func(body: Node2D) -> void:
		if body is Character:
			_characters.erase(body)
		body.remove_from_group(&"state_" + state_for_body)
	)

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
