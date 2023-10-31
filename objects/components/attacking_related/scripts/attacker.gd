extends Component

## Emitted when the callback is done
signal done_receiver_callback

## Temporary reference to attack receiver class
const AttackReceiver: Script = preload("./attack_receiver.gd")

@export_category("Attacker")
## Id of the attacker
@export var attacker_id: StringName
@export var attacker_features: Array[StringName]


func _ready() -> void:
	super()
	
	if !root is Area2D:
		return
	
	root.area_entered.connect(_act_with_attack_receiver)


func _act_with_attack_receiver(area: Area2D) -> void:
	for i: Node in area.get_children():
		if !i is AttackReceiver:
			continue
		i.receive_attacker(self)
