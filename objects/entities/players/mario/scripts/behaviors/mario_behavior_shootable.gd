extends "./mario_behavior_default.gd"

## Emitted when a projectile is shot or thrown
signal projectile_shot(player: Mario2D, projectile: Node2D)

const Attacker: Script = preload("res://objects/components/attacking_related/scripts/attacker.gd")

@export_category("Mario Behavior Shootable")
@export_group("Key Inputs")
## Key of controlling attacking
@export var key_attack: StringName = &"fire"
@export_group("Shooting")
## Projectile to be shot or thrown
@export var projectile: PackedScene
## Maximum of projectiles able to be shot or thrown
@export_range(0, 32, 1, "suffix:x") var projectile_max_amount: int = 2
## ID of the projectile [br]
## [b]Note:[/b] This is used to make the projectiles in the same group to be
## controlled and limited by [member projectile_max_amount], and if you
## don't hope different shootable suits sharing the same maximum amount of projectiles
## to be thrown, please change this property
@export var shooting_id: StringName = &"projectile"
@export_group("Sounds")
## Sound of attacking
@export var sound_attack: AudioStream = preload("res://assets/sounds/shoot.wav")

@onready var pos_attack: Marker2D = $"../Sprite2D/PosAttack"


func _process(delta: float) -> void:
	super(delta)
	_shooting_process()


func _shooting_process() -> void:
	if !mario.is_node_ready():
		return
	elif !projectile:
		return
	elif !Input.is_action_just_pressed(_get_key_input(key_attack)):
		return
	
	# Instantiate projectile
	var prj := projectile.instantiate()
	if !prj is Node2D:
		prj.queue_free()
		return
	
	prj = prj as Node2D
	var prjgp: StringName = mario.character_id + str(mario.id) + prj.name
	if get_tree().get_nodes_in_group(prjgp).size() >= projectile_max_amount:
		prj.queue_free() # Bear in mind to remove unnecessary node in memory!
		return
	
	mario.add_sibling.call_deferred(prj)
	prj.global_transform = mario.global_transform # Do NOT pass pos_attack.global_transform for the projectile due to the minus scale.x
	prj.global_position = pos_attack.global_position # This is to reset the global position to the marker's overriding mario's
	prj.add_to_group(prjgp)
	
	var attacker := Process.iterate_get_child(prj, Attacker)
	if attacker:
		attacker.attacker_features.append(&"player_bullet")
	
	projectile_shot.emit(mario, prj)
	
	sound.play(sound_attack)
	animation.play(&"attack")
