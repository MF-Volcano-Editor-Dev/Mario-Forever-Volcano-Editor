extends Classes.AttackReceiver

## Emitted when the killing is blocked
signal killing_blocked(attacker: Classes.Attacker)

## Emitted when the killing succeeds
signal killing_succeeded(attacker: Classes.Attacker)

@export_category("Enemy Attack Receiver")
@export var block_for_ids: Array[StringName]
@export var block_for_features: Array[StringName]


func _ready() -> void:
	received_attacker.connect(_attacked_process.unbind(1))


func _attacked_process(attacker: Classes.Attacker) -> void:
	if disabled:
		return
	
	if attacker.attacker_id in block_for_ids || attacker.attacker_features in block_for_features:
		killing_blocked.emit(attacker)
	else:
		killing_succeeded.emit(attacker)
