class_name Mario2D extends EntityPlayer2D

@export_group("Suit")
@export var character_id: StringName = &"mario"
@export var suit_id: StringName = &"small":
	set = change_suit
@export var suit_no_appear_animation: bool = true

var _suit: MarioSuit2D:
	get = get_suit


func _ready() -> void:
	change_suit(suit_id)


##regionbegin SuitBehaviors
func change_suit(new_suit_id: StringName) -> void:
	# Removes previous suit
	for i: Node in get_children():
		if !i.is_in_group(&"#mario_cpn_fixed"):
			i.queue_free()
	
	# Prepares and check new suit
	var pid: StringName = PlayerSuits.get_player_suit_id(character_id, new_suit_id)
	var psuit: MarioSuit2D = PlayerSuits.get_player_suit(pid)
	if !psuit:
		return
	
	# Applys the new suit
	suit_id = new_suit_id
	
	# Deploys the new suit
	_suit = psuit
	_suit.deploy(self)
	
	# Appear animation
	if suit_no_appear_animation:
		suit_no_appear_animation = false
	else:
		await _suit.ready # Here must wait for the ready to make sure the suit has been totally deployed
		_suit.appear()


func get_suit() -> MarioSuit2D:
	return _suit
##endregion
