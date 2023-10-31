extends Component

## Emitted when the attacker is received
signal received_attacker(attacker: Component)

## Temporary reference to attacker class
const Attacker: Script = preload("./attacker.gd")

## Filter the [const Attackers] input via [method receive_attacker] by ids in this list
@export_category("Attack Receiver")
@export var filter_attacker_ids: Array[StringName]

## Called when a attacker is received.
## This is often called by [const Attacker]
func receive_attacker(attacker: Attacker) -> void:
	if attacker.attacker_id in filter_attacker_ids:
		return
	
	received_attacker.emit(attacker)
