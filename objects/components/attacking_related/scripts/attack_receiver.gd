extends Component

## Emitted when the attacker is received
signal received_attacker(attacker: Component, receiver: Component)

## Temporary reference to attacker.gd
const Attacker: Script = preload("./attacker.gd")

@export_category("Attack Receiver")
@export_group("Filter")
@export_subgroup("IDs")
## Filters the attackers with ids listed in this property
@export var filter_ids: Array[StringName]
@export_enum("Include", "Exclude") var filter_id_mode: int
@export_subgroup("Features")
## Filters the attackers with features listed in this property
@export var filter_features: Array[StringName]
@export_enum("Include", "Exclude") var filter_feature_mode: int


# Called by attacker
func _receive_attacker(attacker: Component) -> void:
	match filter_id_mode:
		0 when !attacker.attacker_id in filter_ids:
			return
		1 when attacker.attacker_id in filter_ids:
			return
	
	for i: StringName in attacker.attacker_features:
		match filter_feature_mode:
			0 when !i in filter_features:
				return
			1 when i in filter_features:
				return
	
	received_attacker.emit(attacker, self)
	attacker.receiver_called_back.emit(self)
