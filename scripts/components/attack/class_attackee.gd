@tool
@icon("res://icons/attackee.svg")
class_name Attackee extends Component

signal on_hit_by_attacker(attacker: Attacker) ## Emitted when the area is hit by another one that contains an [Attacker].

## Filter mode for [member filter_ids] and [member filter_types]
enum FilterMode {
	INCLUSION, ## In this mode, the collision will be regarded as success if a token is [b]included[/b] in the filter list.
	EXCLUSION ## In this mode, the collision will be regarded as success if a token is [b]excluded[/b] from the filter list.
}

@export_group("Filters")
@export_subgroup("By ID", "filter_ids_")
## Filters the attackers whose ids are listed in the array.
@export var filter_ids: Array[StringName]
## Filter mode of [member filter_ids]. See [enum FilterMode] for details.
@export var filter_ids_mode: FilterMode = FilterMode.INCLUSION
@export_subgroup("By Type", "filter_type_")
## Filters the attackers whose types are equal to the value.
@export var filter_type: Attacker.AttackType = Attacker.AttackType.NEUTRAL
## Filter mode of [member filter_types]. See [enum FilterMode] for details.
@export var filter_type_mode: FilterMode = FilterMode.INCLUSION
@export_group("Sounds", "sound_")
@export var sound_attacked: AudioStream


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if !get_root() is Area2D:
		warnings.append("The component works only when the \"root\" is an Area2D.")
	
	return warnings


func _hit_by_attacker(attacker: Attacker) -> void:
	if !root is Area2D:
		printerr("The \"root\" of the component %s is not an Area2D!" % get_path())
		return
	
	# Filtering
	for i in filter_ids:
		if (filter_ids_mode == FilterMode.EXCLUSION && attacker.id in filter_ids) || \
			(filter_ids_mode == FilterMode.INCLUSION && !attacker.id in filter_ids):
				return
	if attacker.type == Attacker.AttackType.NONE || \
		(filter_type_mode == FilterMode.EXCLUSION && attacker.type == filter_type) || \
		(filter_type_mode == FilterMode.INCLUSION && attacker.type != filter_type):
			return
	
	Sound.play_2d(sound_attacked, root)
	
	on_hit_by_attacker.emit(attacker)
	attacker.attacked_target.emit(attacker)
