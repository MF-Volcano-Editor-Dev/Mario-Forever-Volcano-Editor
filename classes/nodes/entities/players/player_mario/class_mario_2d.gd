class_name Mario2D extends EntityPlayer2D

## An [EntityPlayer2D] for Super Mario Bros. series characters
##
##

# "#mario_component_fixed"

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
@export_group("Health")
## Health point of the player. If zero then the character dies
@export var hp: int = 1:
	set = set_hp

var _suit_ids: Array[StringName]

var _suit: MarioSuit2D
var _invulnerability: SceneTreeTimer

@onready var shape: CollisionShape2D = $Shape
@onready var body: Area2D = $AreaBody
@onready var head: Area2D = $AreaHead
@onready var attack_receiver: Node = $AreaBody/AttackReceiver


func _ready() -> void:
	PlayersManager.register(self)
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
	for i: Node in get_children():
		if !i is MarioSuit2D:
			continue
		elif i.suit_id == suit_id:
			_suit = i
			i.visible = true
			i.process_mode = PROCESS_MODE_INHERIT
		else:
			i.visible = false
			i.process_mode = PROCESS_MODE_DISABLED
		if !i.suit_id in _suit_ids:
			_suit_ids.append(i.suit_id)
	
	# Appear animation
	if suit_no_appear_animation:
		suit_no_appear_animation = false
	else:
		_suit.appear()
	
	suit_changed.emit(suit_id)


## Gets the suit of the character
func get_suit() -> MarioSuit2D:
	return _suit
#endregion


#region Damage Controls
## Makes the character hurt [br]
## tags:
## [codeblock]
## bool forced: If true, when the methods is called, the character will get hurt even though he is invulnerable
##
## int iterations: Determines the times to operate hurting process
##
## bool lose_hp: If true, even though the character will lose his hp regardless of his suit
##
## float duration: The duration of invulnerability after the character takes damage
##
## bool no_sound: If true, then there is not any sound played in hurting process
##
## int hp_loss: Determine how many HPs will an iteration cost
## [/codeblock]
func hurt(tags: Dictionary = {}) -> void:
	if (!&"forced" in tags || tags.forced == false) && is_invulerable():
		return
	
	var itr: int = 1 if !&"iterations" in tags || !tags.iterations is int || tags.iterations <= 0 else tags.iterations # Iterations
	var lshp: bool = false if !&"lose_hp" in tags || !tags.lose_hp is bool else tags.lose_hp # Lose HPs
	var ivdr: float = 2.0 if !&"duration" in tags || !tags.duration is float else tags.duration # Invulnerability duration
	
	# Hurt operation
	for i in itr:
		if !_suit.down_suit_id.is_empty() && _suit.down_suit_id in _suit_ids:
			# Sound controls
			if !&"no_sound" in tags || tags.no_sound == true:
				_suit.sound.play(_suit.sound_hurt, get_tree().current_scene)
			suit_id = _suit.down_suit_id
			invulnerable(ivdr)
		else:
			lshp = true
		
		# Losing HP
		if lshp:
			hp -= 1 if !&"hp_loss" in tags || !tags.hp_loss is int else tags.hp_loss


## Makes the character die
func die(_tags: Dictionary = {}) -> void:
	if _suit.death:
		var d := _suit.death.instantiate()
		if !d is Node2D:
			d.queue_free()
			return
		
		d = d as Node2D
		if d:
			# Here it's not allowed to use call_deferred() 
			# since there is some node to be initialized with @onready
			add_sibling(d)
			d.global_transform = global_transform
			d.sound.stream = _suit.sound_death
	
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


#region Setters & Getters
func set_hp(value: int) -> void:
	# HP++
	if value > hp:
		invulnerable(1)
	# HP--
	elif value < hp:
		invulnerable(3)
	hp = value
	# Check if hp is lower than 0, if so, then makes the player die
	if hp <= 0:
		_invulnerability = null
		die()
#endregion
