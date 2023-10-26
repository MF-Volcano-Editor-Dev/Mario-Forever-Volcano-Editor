class_name Mario2D extends EntityPlayer2D

## An [EntityPlayer2D] for Super Mario Bros. series characters
##
##

# "#mario_component_fixed"

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

var _suit: MarioSuit2D


func _ready() -> void:
	set_suit(suit_id)


#region Suit Behaviors
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
	
	# Removes previous suit
	for i: Node in get_children():
		if !i.is_in_group(&"#mario_component_fixed"):
			i.queue_free()
	
	# Prepares and check new suit
	var pid: StringName = PlayerSuits.get_player_suit_id(character_id, new_suit_id)
	var psuit: MarioSuit2D = PlayerSuits.get_player_suit(pid)
	if !psuit:
		printerr("No such suit %s!" % [psuit])
		return
	
	# Deploys the new suit
	_suit = psuit
	await get_tree().process_frame # Await for one frame to delete the rest of previous suit totally.
	add_child.call_deferred(_suit, true)
	
	# Appear animation
	if suit_no_appear_animation:
		suit_no_appear_animation = false
	else:
		await _suit.ready # Here must wait for the ready to make sure the suit has been totally deployed
		_suit.appear()


## Gets the suit of the character
func get_suit() -> MarioSuit2D:
	return _suit
#endregion


#region Damage Controls
## Makes the character hurt
func hurt() -> void:
	pass


## Makes the character die
func die() -> void:
	pass
#endregion
