class_name EnemyKillingProcess2D extends Instantiater2D

## Used together with [Attackee] to provide instances creation for it.[br]
## 
## This component will instantiate objects based on [member root]. When a character stomps on
## [br]
## [b]Note 1:[/b] This works only when [signal Attackee.on_hit_by_attacker] is connected to [method killing_process].[br]
## [b]Note 2:[/b] You need to and can only add [u]two[/u] [Node2D]s under this component as its children nodes. One should be named as "Success" while the other one as "Defense".

signal killing_processed ## Emitted when the killing is processed.
signal killing_succeeded ## Emitted when the killing process is successful.
signal killing_defended ## Emitted when the killing process is defended.

## Make the enemy immune to the attackers with given ids in the list.[br]
## When an attacker in the list try damaging the enemy, the attack will be defended and [signal killing_defended] will be emitted.
@export var immune_to_ids: Array[DataList.AttackId]
@export_group("Sounds", "sound_")
@export var sound_killed: AudioStream = preload("res://assets/sounds/kick.wav")
@export var sound_killing_defended: AudioStream = preload("res://assets/sounds/kick.wav")


## Called to process killing and instantiate relevant objects.[br]
## [br]
## [b]Note 1:[/b] Please connect [signal EnemyStompable.on_stomp_succeeded] to this call.[br]
## [b]Note 2:[/b] For instances not to be created on failed attack, please merge them in the group [code]instantiate_no_success[/code].
## And for ones not to be created on successful attack, please merge them in the group [code]instantiate_no_failure[/code].
## For ones not to be created on successful attack by attacker who is in the grouop [code]combo[/code], please merge them in the group [code]instantiate_no_success_combo[/code].
func killing_process(attacker: Attacker) -> void:
	killing_processed.emit()
	
	if attacker.id in immune_to_ids:
		Sound.play_2d(sound_killing_defended, self)
		
		instantiate_all(false, [&"instantiate_no_failure"])
		killing_defended.emit()
		attacker.attack_failed.emit()
	else:
		var is_combo: = false
		var filters: Array[StringName] = [&"instantiate_no_success"]
		
		if attacker.is_in_group(&"combo"):
			is_combo = true
			filters.append(&"instantiate_no_success_combo")
		
		if !is_combo:
			Sound.play_2d(sound_killed, self)
		
		instantiate_all(false, filters)
		killing_succeeded.emit()
		attacker.attack_succeeded.emit()
