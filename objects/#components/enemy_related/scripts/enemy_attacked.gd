extends Component

## Emitted when the killing is blocked
signal killing_blocked(attacker: Classes.Attacker)

## Emitted when the killing succeeds
signal killing_succeeded(attacker: Classes.Attacker)

@export_category("Enemy Attacked")
@export var disabled: bool
@export var block_for_ids: Array[StringName]
@export var block_for_features: Array[StringName]


func _ready() -> void:
	super()
	
	if is_instance_of(root, Classes.Attacker):
		return
	
	root.received_attacker.connect(_attack_process_signals.unbind(1))


func _attack_process_signals(attacker: Classes.Attacker) -> void:
	if disabled:
		return
	if attacker.attacker_id in block_for_ids || attacker.attacker_features in block_for_features:
		killing_blocked.emit(attacker)
	else:
		killing_succeeded.emit(attacker)
