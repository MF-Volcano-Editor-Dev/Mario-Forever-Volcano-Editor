extends Component

## Attack processor for an [Area2D], you need an [constant AttackReceiver] component for those [Area2D]s
## who are able to receive the attacker when the area collides with them
##
## List of values available in [member attacker_features]: [br]
## * player_bullet: Bullet thrown by [b]player[/b] [br]
## * enemy_bullet: Bullet thrown by [b]enemy[/b] [br]
## * player_bullet_pvp: <PlayerID>: Bullet thrown by [b]player[/b] with [u]specific player id[/u] (WIP) [br]

## Emitted when hitting the receiver
signal hit_receiver(receiver: Component)

## Emitted when the receiver send callback
signal receiver_called_back(receiver: Component)

## Temporary reference to attack_receiver.gd
const AttackReceiver: Script = preload("./attack_receiver.gd")

@export_category("Attacker")
## Id of the attacker
@export var attacker_id: StringName
## Features of attacker, see the list above
@export var attacker_features: Array[StringName]


func _ready() -> void:
	super()
	
	if !root is Area2D:
		return
	
	root.area_entered.connect(_act_with_attack_receiver)


func _act_with_attack_receiver(area: Area2D) -> void:
	for i: Node in area.get_children():
		if i is AttackReceiver:
			hit_receiver.emit(i)
			i._receive_attacker(self)
			break
