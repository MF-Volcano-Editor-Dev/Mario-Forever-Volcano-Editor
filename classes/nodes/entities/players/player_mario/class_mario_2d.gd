class_name Mario2D extends EntityPlayer2D

## An [EntityPlayer2D] for Super Mario Bros. series characters
##
##

## Emitted when the player gets damage with health lost
signal lost_health(amount: float)

## Emitted when the [member suit_id] gets changed
signal suit_changed(to: StringName)

@export_group("Suit")
## Name of current suit
## [b]Note:[/b] changing this method will automatically change
## the suit of the character, and to make sure the suit id can be found
## during the modification, please make sure the same property in [MarioSuit2D]
## matches this one before the adjustment
@export var suit_id: StringName = &"small":
	set = set_suit
## If [code]true[/code], the character's appearing animation won't be played.
## This is often used at the very beginning of the scene
@export var suit_no_appear_animation: bool = true

var _suit_refs: Array[Classes.MarioSuit2D]
var _suit_ids: Array[StringName]

var _suit: Classes.MarioSuit2D
var _invulnerability: SceneTreeTimer

@onready var shape: CollisionShape2D = $Shape
@onready var body: Area2D = $AreaBody
@onready var head: Area2D = $AreaHead
@onready var attack_receiver: Node = $AreaBody/AttackReceiver
@onready var shape_controller: AnimationPlayer = $AnimationShape
@onready var health: Classes.HealthComponent = $AreaBody/HealthComponent


func _ready() -> void:
	# Replace player with existing one if the player
	# is cached
	var pl := PlayersManager.get_player(id)
	if pl:
		visible = false
		
		pl.global_transform = global_transform
		PlayersManager.add_player(id, get_parent())
		
		queue_free()
		return
	
	# Register player
	PlayersManager.register(self)
	
	# Register suits
	for i: Node in get_children():
		if !i is Classes.MarioSuit2D || i in _suit_refs:
			continue
		_suit_refs.append(i)
		_suit_ids.append(i.suit_id)
	
	# Set initial suit
	set_suit(suit_id)


#region Suit Behaviors
## Overrides one in the super class
func set_character_id(new_character_id: StringName) -> void:
	super(new_character_id)
	set_suit(suit_id)


## Changes the suit of the character, automatically called when [member suit_id]
## gets changed
## [b]Note:[/b] This method will load the suit from [singleton PlayerSuits], so please
## tag the suit under the singleton before calling this method
func set_suit(new_suit_id: StringName) -> void:
	# Applys the new suit
	suit_id = new_suit_id
	
	# Stop running if the node is on initialization
	if !is_node_ready():
		return
	
	_suit = null
	for i: Classes.MarioSuit2D in _suit_refs:
		if i.suit_id == suit_id:
			_suit = i
			i.visible = true
			i.process_mode = PROCESS_MODE_INHERIT
			add_shape_lib(i.shape_lib_name, i.shape_lib)
			set_shape_state.call_deferred(i.shape_lib_name, &"RESET")
		else:
			i.visible = false
			i.process_mode = PROCESS_MODE_DISABLED
	
	# Appear animation
	if suit_no_appear_animation:
		suit_no_appear_animation = false
	else:
		_suit.appear()
	
	suit_changed.emit(suit_id)


## Gets the suit of the character
func get_suit() -> Classes.MarioSuit2D:
	return _suit
#endregion


#region Damage Controls
## Makes the character hurt [br]
func hurt() -> void:
	if state_machine.is_state(&"no_hurt") || (!get_meta(&"hurt_forced", false) && is_invulerable()):
		return
	
	var itr: int = get_meta(&"hurt_iterations", 1) # Iterations
	var lshp: bool = get_meta(&"hurt_force_lose_health", false) # Lose HPs
	var ivdr: float = get_meta(&"hurt_invulerability_duration", 2.0) # Invulnerability duration
	
	# Hurt operation
	for i in itr:
		if !_suit.down_suit_id.is_empty() && _suit.down_suit_id in _suit_ids:
			# Sound controls
			if get_meta(&"hurt_sound", true):
				Sound.play_sound_2d(self, _suit.sound_hurt)
			suit_id = _suit.down_suit_id
			invulnerable(ivdr)
		else:
			lshp = true
		
		# Losing HP
		if lshp:
			var dmg: float = get_meta(&"hurt_damage", 1.0)
			lost_health.emit(dmg)
			health.sub_health(dmg)
			
			if health.health > 0:
				if get_meta(&"hurt_sound", true):
					Sound.play_sound_2d(self, _suit.sound_hurt)
				
				invulnerable(ivdr)
				
				var tw := create_tween().set_loops(10).set_trans(Tween.TRANS_SINE).set_parallel(true)
				var g := modulate.g
				var b := modulate.b
				tw.tween_property(self, ^"modulate:g", 0.1, 0.05)
				tw.tween_property(self, ^"modulate:b", 0.1, 0.05)
				tw.chain().tween_property(self, ^"modulate:g", g, 0.05)
				tw.chain().tween_property(self, ^"modulate:b", b, 0.05)
			else:
				_invulnerability = null
				die()
	
	# Remove meta tags
	remove_meta(&"hurt_forced")
	remove_meta(&"hurt_iterations")
	remove_meta(&"hurt_force_lose_health")
	remove_meta(&"hurt_invulerability_duration")
	remove_meta(&"hurt_sound")
	remove_meta(&"hurt_damage")


## Makes the character die
func die() -> void:
	if state_machine.is_state(&"no_death"):
		return
	
	if get_meta(&"death_with_body", true) && _suit.death:
		var d := _suit.death.instantiate()
		if !d is Node2D:
			d.queue_free()
			return
		
		d = d as Node2D
		if d:
			# Here it's not allowed to use call_deferred() on add_sibling()
			# since there is some node to be initialized with @onready
			d.global_transform = global_transform
			d.sound_death = _suit.sound_death
			add_sibling(d)
	
	remove_meta(&"death_with_body")
	
	PlayersManager.unregister(id)
	queue_free()


## Makes the player invulnerable for [param duration] seconds [br]
## [b]Note:[/b] If the method is called during the invulerability, the duration will be freshed
func invulnerable(duration: float = 2.0) -> void:
	_invulnerability = get_tree().create_timer(duration, false)
	
	Effects2D.flash(self, duration)
	
	# Clear the reference after the timer is over
	await _invulnerability.timeout
	_invulnerability = null


## Returns [code]true[/code] if the character is invulnerable
func is_invulerable() -> bool:
	return _invulnerability != null
#endregion


#region Meta Control
## Sets [member shape_controller]'s animation library, which can provide a set of shape states for
## the shapes of the character
func add_shape_lib(shape_lib_name: StringName, shape_lib: AnimationLibrary, override: bool = false) -> void:
	if shape_lib_name.is_empty() || shape_controller.get_animation_library(shape_lib_name) == shape_lib:
		return
	if override:
		shape_controller.remove_animation_library(shape_lib_name)
	if !shape_controller.has_animation_library(shape_lib_name):
		shape_controller.add_animation_library(shape_lib_name, shape_lib)


## Sets [member shape_controller]'s current animation to make a shape state work [br]
## [b]Note:[/b] It should be mentioned that [code]&"RESET"[/code] is the name of default state
func set_shape_state(shape_lib_name: StringName, shape_state: StringName) -> void:
	var st := shape_lib_name + &"/" + shape_state
	if !shape_controller.has_animation(st):
		printerr("No such shape state \"lib: %s; state: %s\" found!" % [shape_lib_name, shape_state])
		return
	shape_controller.play.call_deferred(st)
#endregion
