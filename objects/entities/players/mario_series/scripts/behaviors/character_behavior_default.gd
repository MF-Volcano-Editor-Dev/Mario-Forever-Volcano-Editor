extends CharacterBehavior2D

const ActionSwim := preload("./actions/character_action_swimming.gd")
const ActionClimb := preload("./actions/character_action_climbing.gd")

@export_category("Behavior Default")
@export_enum("Default", "8-Direction (No Gravity)") var mode: int
@export_group("Gravity")
## Overrides the character's [member EntityBody2D.gravity]
@export_range(-1, 1, 0.001, "or_greater", "hide_slider", "suffix:x") var gravity_scale: float = 1
## Overrides the character's [member EntityBody2D.max_falling_speed]
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s²") var max_falling_speed: float = 500


func _physics_process(delta: float) -> void:
	if disabled:
		return
	
	character.gravity_scale = gravity_scale
	character.max_falling_speed = max_falling_speed
	
	match mode:
		0: # Default
			character.move_and_slide()
			character.correct_onto_floor()
			character.correct_on_wall_corner()
		1: # 8-Direction (No Gravity)
			var kc := character.move_and_collide(character.global_velocity * delta)
			if kc:
				character.global_velocity = character.global_velocity.slide(kc.get_normal())
	
	var body_overlaps := character.body.get_overlapping_areas()
	var head_overlaps := character.head.get_overlapping_areas()
	
	_overlaps_water(body_overlaps)
	_overlaps_climbable(body_overlaps)
	_head_water(head_overlaps)


#region == Overlapping process ==
func _overlaps_water(overlaps: Array[Area2D]) -> void:
	var count := 0
	
	for i: Area2D in overlaps:
		if i is AreaFluid2D && i.character_swimmable:
			overlaps.erase(i)
			count += 1
	
	ObjectState.set_state(character, ActionSwim.STATE_SWIMMING, count > 0)

func _overlaps_climbable(overlaps: Array[Area2D]) -> void:
	var count := 0
	var is_climbing := ObjectState.is_state(character, ActionClimb.STATE_CLIMBING)
	
	for i: Area2D in overlaps:
		if i.is_in_group(&"%%climbable"):
			overlaps.erase(i)
			count += 1
	
	ObjectState.set_state(character, ActionClimb.STATE_CLIMBABLE, count > 0)
	ObjectState.set_state(character, ActionClimb.STATE_CLIMBING, count > 0 && is_climbing)

func _head_water(overlaps: Array[Area2D]) -> void:
	var count := 0
	
	for i: Area2D in overlaps:
		if i is AreaFluid2D && i.character_swimmable:
			overlaps.erase(i)
			count += 1
	
	ObjectState.set_state(character, ActionSwim.STATE_SWIMMING_OUT, count <= 0)
#endregion
