extends Component

## Attack processor for an [Area2D], you need an [constant Classes.AttackReceiver] component for those [Area2D]s
## who are able to receive the attacker when the area collides with them
##
## List of values available in [member attacker_features]: [br]
## * player_bullet: Bullet thrown by [b]player[/b] [br]
## * enemy_bullet: Bullet thrown by [b]enemy[/b] [br]
## * player_bullet_pvp: <PlayerID>: Bullet thrown by [b]player[/b] with [u]specific player id[/u] (WIP) [br]
## * ice_freezing: Bullet that will make an enemy frozen (WIP)(Needs ice-flower module) [br]

## Emitted when hitting the receiver
signal hit_receiver(receiver: Classes.AttackReceiver)

## Emitted when the receiver send callback
signal receiver_called_back(receiver: Classes.AttackReceiver)

@export_category("Attacker")
@export var disabled: bool
## Id of the attacker
@export var attacker_id: StringName
## Features of attacker, see the list above
@export var attacker_features: Array[StringName]
## Damage of the attacker
@export_range(0, 1, 0.01, "or_greater", "hide_slider", "suffix:♥") var attacker_damage: float = 1
## Mode of detection [br]
## [b]Note:[/b] The "Per Frame" mode is a performance consumer, so be careful if you want to shift to this mode
@export_enum("Once", "Per Frame") var attack_process_mode: int

var _ignored_thrower_areas: Array[Area2D]
var _attack_receivers: Array[Classes.AttackReceiver]


func _ready() -> void:
	super()
	
	if !root is Area2D:
		return
	
	root.area_entered.connect(_act_with_attack_receiver)
	root.area_exited.connect(_remove_attack_receiver)


func _process(_delta: float) -> void:
	if disabled || attack_process_mode != 1:
		return
	
	for i: Classes.AttackReceiver in _attack_receivers:
		_act_with_receiver(i)


func ignore_thrower_area(thrower_area: Area2D) -> void:
	if thrower_area in _ignored_thrower_areas:
		return
	_ignored_thrower_areas.append(thrower_area)


func _act_with_receiver(receiver: Classes.AttackReceiver) -> void:
	if disabled:
		return
	
	hit_receiver.emit(receiver)
	receiver._receive_attacker(self)


func _act_with_attack_receiver(area: Area2D) -> void:
	if disabled || area == root:
		return
	elif area in _ignored_thrower_areas:
		_ignored_thrower_areas.erase(area)
		return
	
	var atrc: Classes.AttackReceiver = Process.get_child(area, Classes.AttackReceiver)
	if !atrc:
		return
	
	if attack_process_mode == 0:
		_act_with_receiver(atrc)
	elif !atrc in _attack_receivers:
		_attack_receivers.append(atrc)


func _remove_attack_receiver(area: Area2D) -> void:
	if attack_process_mode != 1:
		return
	
	var atrc: Classes.AttackReceiver = Process.get_child(area, Classes.AttackReceiver)
	if atrc && atrc in _attack_receivers:
		_attack_receivers.erase(atrc)
