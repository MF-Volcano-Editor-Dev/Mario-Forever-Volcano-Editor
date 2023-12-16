@icon("res://icons/attack_receiver.svg")
class_name AttackReceiver extends Component

## Class that works together with [Attacker]
##
## [b]Note:[/b] This node [b]MUST[/b] be a [u]DIRECT[/u] child of [Area2D], unlike [Attacker], and the [member root_path] should point to the
## [Area2D] as well.

signal attack_received ## Emitted when the attacker's attack is received
signal attack_damage_received(amount: int) ## Emitted right after the emission of [signal attack_received] when the damage is received from the attacker
signal attack_tags_received(tags: TagsObject) ## Emitted right after the emission of [signal attack_damage] when an [TagsObject] is received from the attacker
signal attack_blocked ## Emitted when the attacker's attack is blocked

@export_category("Attack Receiver")
## Defines which [member Attacker.attacker_source] will be ignored.
@export var ignored_attacker_sources: Array[StringName]
## Defines which [member Attacker.attacker_features] will be blocked.
@export var blocked_attacker_features: Array[StringName]
@export_group("Sounds", "sound_")
@export var sound_blocked: AudioStream = preload("res://assets/sounds/bump.wav") ## Sound of blocking an attack

@onready var _root := get_root() as Area2D


#region == Attack received ==
## Receives the attacker's attack.[br]
## [br]
## [b]Note:[/b] This method can be called ONLY by [Attacker] automatically.
func attacker_attacked(attacker: Attacker) -> void:
	_root.monitoring = _root.monitoring
	if disabled || attacker.attacker_source.is_empty() || attacker.attacker_source in ignored_attacker_sources || attacker.attacker_features.is_empty():
		return
	for i: StringName in attacker.attacker_features:
		if i in blocked_attacker_features:
			Sound.play_sound_2d(_root, sound_blocked)
			attacker.attack_got_blocked.emit()
			attack_blocked.emit()
			return
	_attack_received_emit(attacker)

func _attack_received_emit(attacker: Attacker) -> void:
	attacker.attack_got_received.emit()
	attack_received.emit()
	attack_damage_received.emit(attacker.attacker_damage)
	attack_tags_received.emit(attacker.attacker_tags)
#endregion
