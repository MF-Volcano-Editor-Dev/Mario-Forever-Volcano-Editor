@tool
@icon("res://icons/attacker.svg")
class_name Attacker extends Component

signal attacked_target(target: Attackee) ## Emitted when the area collides with another one containing [Attackee] and the interaction with the [Attackee] is successful.

## Types of attack
enum AttackType {
	NONE, ## No attack
	PLAYER, ## Attack by player
	ENEMY, ## Attack by enemy
	NEUTRAL, ## Attack by nobody
}

## Id of the attacker. See [member Attackee.filter_ids] and [enum Attackee.FilterMode] for details.
@export var id: StringName
## Types of the attacker. See [member Attackee.filter_types] and [enum Attackee.FilterMode] for deails.
@export var type: AttackType = AttackType.NONE


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	(root as Area2D).area_entered.connect(_on_attacked_attackee)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if !get_root() is Area2D:
		warnings.append("The component works only when the \"root\" is an Area2D.")
	
	return warnings


func _on_attacked_attackee(area: Area2D) -> void:
	for i in area.get_children():
		if !i is Attackee:
			continue
		
		i._hit_by_attacker(self)
		break
