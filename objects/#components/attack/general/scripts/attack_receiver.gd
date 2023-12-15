@icon("res://icons/attack_receiver.svg")
class_name AttackReceiver extends Component

## Class that works together with [Attacker]
##
##

signal attack_received(attacker: Attacker) ## Emitted when the attacker's attack is received
signal attack_damage_received(amount: int) ## Emitted right after the emission of [signal attack_received]
signal attack_tags_received(tags: TagsObject) ## Emitted right after the emission of [signal attack_damage]
signal attack_blocked ## Emitted when the attacker's attack is blocked

@export_category("Attack Receiver")
@export var ignored_attacker_sources: Array[StringName]
@export var blocked_attacker_features: Array[StringName]
@export_group("Sounds", "sound_")
@export var sound_blocked: AudioStream = preload("res://assets/sounds/bump.wav")

@onready var _root := get_root() as Area2D


## Receives the attacker's attack.[br]
## [br]
## [b]Note:[/b] This method can be called only by [Attacker] automatically.
func attacker_attacked(attacker: Attacker) -> void:
	if disabled || attacker.attacker_source.is_empty() || attacker.attacker_source in ignored_attacker_sources || attacker.attacker_features.is_empty():
		return
	for i: StringName in attacker.attacker_features:
		if i in blocked_attacker_features:
			Sound.play_sound_2d(_root, sound_blocked)
			attacker.attack_got_blocked.emit(self)
			attack_blocked.emit()
			return
	attacker.attack_got_received.emit(self)
	attack_received.emit(attacker)
	attack_damage_received.emit(attacker.attacker_damage)
	attack_tags_received.emit(attacker.attacker_tags)
