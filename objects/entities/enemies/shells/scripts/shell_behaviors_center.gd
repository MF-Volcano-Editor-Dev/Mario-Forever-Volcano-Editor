extends Component

@export_category("Shell Behavior")
@export var move: bool:
	set(value):
		move = value
		(func() -> void:
			if move:
				start_movement()
			else:
				stop_movement()
		).call_deferred() # Called deferredly to make sure the `_ready()` function works first
@export_group("Component Links", "path_")
@export_node_path("Node") var path_attacker: NodePath = ^"../Area2D/Attacker"
@export_node_path("Node") var path_attack_receiver: NodePath = ^"../Area2D/AttackReceiverEnemy"
@export_node_path("Node") var path_enemy_stompable: NodePath = ^"../Area2D/EnemyTouchStomp"
@export_node_path("Node") var path_solid_entity: NodePath = ^"../Area2D/SolidEntity"
@export_node_path("AnimatedSprite2D") var path_sprite: NodePath = ^"../AnimatedSprite2D"
@export_group("Sounds", "sound_")
@export var sound_stomped: AudioStream = preload("res://assets/sounds/stomp.wav")
@export var sound_kicked: AudioStream = preload("res://assets/sounds/kick.wav")
@export_subgroup("Collision", "sound_")
@export var sound_colliding_wall: AudioStream = preload("res://assets/sounds/bump.wav")

var _kicker: CharacterEntity2D
var _speed: float
var _delayer: SceneTreeTimer
var _blocked_attacker_features: Array[StringName]

@onready var _root := get_root() as Node2D
@onready var _attacker := get_attacker()
@onready var _attack_receiver := get_attack_receiver()
@onready var _enemy_stompable := get_enemy_stompable()
@onready var _solid_entity := get_solid_entity()
@onready var _sprite := get_sprite()


func _ready() -> void:
	_speed = _root.velocity.x
	# Gets the `move` metadata from the root node
	move = _root.get_meta(&"move", move)


#region == Movement control ==
func start_movement() -> void:
	if disabled || _delayer:
		return
	
	_root.velocity.x = _speed
	_root.initial_direction = 2 if _kicker else 1
	_root.update_direction()
	_sprite.play(&"default")
	
	if !_blocked_attacker_features.is_empty():
		_attack_receiver.blocked_attacker_features = _blocked_attacker_features
		_blocked_attacker_features.clear()
	
	_attacker.disabled = false
	_solid_entity.disabled = true
	_enemy_stompable.disabled = true
	await _delay(0.25).timeout
	_enemy_stompable.disabled = false
	_enemy_stompable.harmless = false
	_enemy_stompable.disable_stompability = false

func stop_movement() -> void:
	if disabled:
		return
	
	_root.velocity.x = 0
	_sprite.stop()
	
	if _blocked_attacker_features.is_empty():
		_blocked_attacker_features = _attack_receiver.blocked_attacker_features
		_attack_receiver.blocked_attacker_features.clear()
	
	_attacker.disabled = true
	_solid_entity.disabled = false
	_enemy_stompable.harmless = true
	_enemy_stompable.disable_stompability = true
#endregion

#region == Interface of movement handling ==
func _on_character_touched(character: CharacterEntity2D = null) -> void:
	if disabled:
		return
	Sound.play_sound_2d(_root, sound_kicked)
	_kicker = character
	# TODO: API for helding a shell
	# CAUTION: DO NOT remove this code if you want to implement holding a shell!
	#var flagger := character.get_flagger()
	#while flagger.is_flag(&"shell_holding"):
	#	await get_tree().process_frame
	# Starts movement
	move = true

func _on_stomped() -> void:
	if disabled || _delayer:
		return
	Sound.play_sound_2d(_root, sound_stomped)
	# Creates delayer to prevent from immediate kick
	_delay()
	# Stops movement
	move = false

func _delay(duration: float = 0.2) -> SceneTreeTimer:
	_delayer = get_tree().create_timer(duration, false)
	_delayer.timeout.connect(
		func() -> void:
			_delayer = null
	)
	return _delayer
#endregion

func play_sound_colliding_wall() -> void:
	Sound.play_sound_2d(_root, sound_colliding_wall)

#region == Getters ==
func get_attacker() -> Attacker:
	return get_node(path_attacker) as Attacker

func get_attack_receiver() -> AttackReceiverEnemy:
	return get_node(path_attack_receiver) as AttackReceiverEnemy

func get_enemy_stompable() -> EnemyTouchStomp:
	return get_node(path_enemy_stompable) as EnemyTouchStomp

func get_solid_entity() -> SolidEntity:
	return get_node(path_solid_entity) as SolidEntity

func get_sprite() -> AnimatedSprite2D:
	return get_node(path_sprite) as AnimatedSprite2D
#endregion
