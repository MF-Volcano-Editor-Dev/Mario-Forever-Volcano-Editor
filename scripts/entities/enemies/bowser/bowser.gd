extends Walker2D

signal bowser_in_screen ## Emitted when the bowser comes in the screen. This is used to trigger the hud to display.
signal bowser_defeated ## Emitted when the bowser dies.
signal bowser_health_changed ## Emitted when the [member health] gets changed.
signal bowser_damaged ## Emitted when bowser gets damaged.

@export_category("Bowser")
@export_range(1, 20, 1, "or_greater", "suffix:♥") var health: int = 5:
	set(value):
		health = value
		bowser_health_changed.emit()
@export_range(0, 20, 0.001, "suffix:s") var invulnerability_duration: float = 2
@export_group("Defense")
@export_range(0, 100) var defendable_stomps: int = 1
@export_range(0, 1000) var defendable_attacks: int = 5
@export_group("References")
@export_node_path("EnemyStompable") var enemy_stompable_path: NodePath = ^"EffectBox/EnemyStompable"
@export_node_path("Instantiater2D") var flame_path: NodePath = ^"Flame"
@export_node_path("Instantiater2D") var hammer_path: NodePath = ^"Hammer"
@export_node_path("Instantiater2D") var corpse_path: NodePath = ^"Corpse"
@export_group("Sounds", "sound_")
@export var sound_hurt: AudioStream = preload("res://assets/sounds/bowser_hurt.wav")
@export var sound_death: AudioStream = preload("res://assets/sounds/bowser_died.wav")

var _invulnerable: bool
var _defended_stomp: int
var _defended_attacks: int

@onready var _enemy_stompable: EnemyStompable = get_node(enemy_stompable_path)
@onready var _flame: Instantiater2D = get_node(flame_path)
@onready var _hammer: Instantiater2D = get_node(hammer_path)
@onready var _corpse: Instantiater2D = get_node(corpse_path)


func _ready() -> void:
	health = health # Triggers setter to help with the emission of bowser_health_changed

func _physics_process(delta: float) -> void:
	calculate_gravity()
	move_and_slide(enable_real_velocity)
	
	var np := Character.Getter.get_nearest(get_tree(), global_position)
	if !np:
		return
	
	set_meta(&"facing", Transform2DAlgo.get_direction_to_regardless_transform(global_position, np.global_position, global_transform))


func _on_attacker_attacked() -> void:
	if _invulnerable:
		return
	
	_defended_attacks += 1
	if _defended_attacks >= defendable_attacks:
		_on_damaged()

func _on_stomped() -> void:
	if _invulnerable:
		return
	
	_defended_stomp += 1
	if _defended_stomp >= defendable_stomps:
		_on_damaged()

func _on_damaged() -> void:
	if _invulnerable:
		return
	
	_defended_attacks = 0
	_defended_stomp = 0
	
	health -= 1
	
	if health > 0:
		Sound.play_2d(sound_hurt, self)
		
		_invulnerable = true
		_enemy_stompable.stompable = false
		
		Effects.flash(self, invulnerability_duration, 0.5)
		await get_tree().create_timer(invulnerability_duration, false).timeout
		
		_invulnerable = false
		_enemy_stompable.stompable = true
	else:
		Sound.play_2d(sound_death, self)
		Events.EventTimeDown.get_signals().time_down_paused.emit()
		bowser_defeated.emit()

func _on_bowser_defeated() -> void:
	var items := _corpse.instantiate_all()
	for i in items:
		if i is EntityBody2D:
			i.set_meta(&"facing", get_meta(&"facing", 1))

func _on_bowser_entered_screen() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	bowser_in_screen.emit()
