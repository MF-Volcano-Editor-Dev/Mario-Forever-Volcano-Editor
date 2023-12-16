@icon("res://icons/attacker.svg")
class_name Attacker extends AreaDetectingComponent

## Class that works together with [AttackReceiver]
##
## [b]Note:[/b] The [member root_path] should point to an [Area2D].

signal attack_got_received ## Emitted when an attack receiver receives the attack
signal attack_got_blocked ## Emitted when an attack receiver blocks the attack

@export_category("Attacker")
## Source type of the attacker[br]
## [br]
## [b]Note:[/b] The attack from attacker with [member attack_source] empty or listed in [member AttackReceiver.ignored_attacker_sources]
## will be ignored by the attack receiver.
@export var attacker_source: StringName
## Features of the attacker[br]
## [br]
## [b]Note:[/b] The features listed in [member AttackReceiver.blocked_attacker_features] will be blocked by the attack receiver.
@export var attacker_features: Array[StringName]
## Damage of the attacker.
## This will lead to emission of [signal AttackReceiver.attack_damage_received].
@export_range(0, 1, 1, "suffix:♥") var attacker_damage: int = 1
## Tags to pass to the attack receiver.
## This will lead to emission of [signal AttackReceiver.attack_tags_received].
@export var attacker_tags: TagsObject
@export_group("Detection")
## If [code]true[/code], the attacker will detect the area's entering and exiting
## in each physics frame. Otherwise, the attacker will detect once on other area's entering or exiting.
@export var continuous_detection: bool:
	set(value):
		continuous_detection = value
		process_mode = PROCESS_MODE_INHERIT if continuous_detection else PROCESS_MODE_DISABLED
@export_group("Sounds", "sound_")
@export var sound_attacked: AudioStream ## Sound of working with the attack receiver

var attack_received: bool # This should be changed by AttackReceiver
var attack_blocked: bool # This should be changed by AttackReceiver

@onready var _root := get_root() as Area2D


func _ready() -> void:
	_root.area_entered.connect(_on_checking_attack_receiver)


func _process(_delta: float) -> void:
	_root.set_deferred(&"monitoring", false)
	_root.set_deferred(&"monitoring", true)


func _on_checking_attack_receiver(area: Area2D) -> void:
	if disabled || is_area_ignored(area):
		return
	var attack_receiver := Process.get_child(area, AttackReceiver) as AttackReceiver
	if !attack_receiver:
		return
	attack_receiver.attacker_attacked(self)
	if attack_blocked:
		return
	Sound.play_sound_2d(_root, sound_attacked) # Plays the sound when the attack is received
