class_name AttackReceiverEnemy extends AttackReceiver

##
##
##

signal attack_received_combo ## Emitted when an attack is received from an attacker without "combo" feature
signal attack_received_no_combo ## Emitted when an attack is received from an attacker without "combo" feature

@export_category("Attack Enemy Receiver")
@export var combo_features: Array[StringName] = [&"combo"]


func attacker_attacked(attacker: Attacker) -> void:
	if disabled || attacker.attacker_source.is_empty() || attacker.attacker_source in ignored_attacker_sources || attacker.attacker_features.is_empty():
		return
	var with_combo: bool = false
	for i: StringName in attacker.attacker_features:
		if i in blocked_attacker_features:
			Sound.play_sound_2d(_root, sound_blocked)
			attacker.attack_got_blocked.emit()
			attack_blocked.emit()
			return
		elif i in combo_features:
			with_combo = true
	if with_combo:
		attack_received_combo.emit()
	else:
		attack_received_no_combo.emit()
	_attack_received_emit(attacker)
