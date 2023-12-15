extends CharacterBehavior2D

signal shooted_projectile ## Emitted when the character is about to throw (a) projectile(s)

@export_category("Character Shoot")
@export_group("Keys")
@export var key_shoot: StringName = &"fire"
@export_group("Projectile Settings")
@export var projectile_group: StringName
@export_range(0, 10, 1) var projectiles_maximum: int = 2

@onready var _animation := get_power().get_animation()


func _process(_delta: float) -> void:
	var fire := _character.is_action_just_pressed(key_shoot)
	if fire && !_flagger.is_flag(&"is_crouching"):
		var group := get_projectile_group()
		if get_tree().get_nodes_in_group(group).size() > projectiles_maximum - 1:
			return
		shooted_projectile.emit()


func get_projectile_group() -> StringName:
	return &"%%projectile-%s-%s" % [str(_character.get_instance_id()), projectile_group]


func _on_projectile_created(instance: Node2D) -> void:
	_animation.play(&"attack")
	instance.add_to_group(get_projectile_group())
	var attacker := Process.get_child_iterate(instance, Attacker) as Attacker
	if !attacker:
		return
	attacker.attacker_source = &"player"
