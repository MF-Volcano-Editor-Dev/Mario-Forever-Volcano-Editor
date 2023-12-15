@icon("res://icons/attacker.svg")
class_name Attacker extends Component

## Class that works together with [AttackReceiver]
##
##

signal attack_got_received(attack_receiver: AttackReceiver) ## Emitted when an attack receiver receives the attack
signal attack_got_blocked(attack_receiver: AttackReceiver) ## Emitted when an attack receiver blocks the attack

@export_category("Attacker")
@export var attacker_source: StringName
@export var attacker_features: Array[StringName]
@export_range(0, 1, 1, "suffix:♥") var attacker_damage: int = 1
@export var attacker_tags: TagsObject
@export_group("Sounds", "sound_")
@export var sound_attacked: AudioStream

var attack_received: bool # This should be changed by AttackReceiver
var attack_blocked: bool # This should be changed by AttackReceiver

@onready var _root := get_root() as Area2D


func _ready() -> void:
	_root.area_entered.connect(_on_checking_attack_receiver)


func _on_checking_attack_receiver(area: Area2D) -> void:
	if disabled:
		return
	var attack_receiver := Process.get_child(area, AttackReceiver) as AttackReceiver
	if !attack_receiver:
		return
	attack_receiver.attacker_attacked(self)
	Sound.play_sound_2d(_root, sound_attacked)
