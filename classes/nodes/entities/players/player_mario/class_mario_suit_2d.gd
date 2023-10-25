class_name MarioSuit2D extends Node2D

## A kind of component only used for [Mario2D] to provide
## fast-modifible module for the character

@export_group("General")
## [member EntityBody2D.character_id] of the character [br]
## [b]Note:[/b] This is used for suit registeration, and MUST keep the same
## as one in the character you are looking for
@export var character_id: StringName = &"mario"
## Id of the suit, also used in [member Mario2D][br]
## [b]Note:[/b] This is used for suit registeration, see [member Mario2D.suit_id]
@export var suit_id: StringName = &"small"
## The [member suit_id] of the suit when the player gets hurt [br]
## If this is empty, the character will die when getting damaged
@export var down_suit_id: StringName = &""
## Features of the suit, effects some of the results of [member behavior][br]
## Use "," to separate each features and use "_" to take the place if space
@export var suit_features: String = ""
@export_group("Direct-manage Nodes")
## Nodes that will be moved under the character node [br]
## [b]Note:[/b] Some nodes, like [CollisionShape2D], should be listed in this property![br]
## [color=yellow][b]Attention![/b][/color] In the spector, you need to manually initialize the nodes to be managed by the character directly
@export var direct_manage_nodes: Array[Node]
@export_group("Shapes")
## Shapes that should be controlled, see [method switch_shape]
@export var shapes_list: Dictionary = {
	&"normal": [],
	&"crouch": []
}
## [Sprite2D] of the suit
@onready var sprite: Sprite2D = $Sprite2D
## [AnimationPlayer] of the suit to control displaying of [member sprite]
@onready var animation: AnimationPlayer = $AnimationPlayer
## [Component] of the suit that process core codes
@onready var behavior: Node = $Behavior

var _player: Mario2D

## Deploys the suit for a [Mario2D] and link the [Mario2D] with this suit instance [br]
## [b]Note:[/b] This method is a [color=cyan][b]coroutine[/b][/color] for the safety
## of the deployment when the player node is just initialized and it calls this method
## immediately
func deploy(on: Mario2D) -> void:
	# Wait for the readiness of the player body to
	# safely deploy the components
	if !is_instance_valid(on):
		return
	elif !on.is_node_ready():
		await on.ready
	
	# Some nodes, like CollisonShape2D, should be directly
	# managed by the player body
	for k: Node in direct_manage_nodes:
		k.reparent.call_deferred(on, false)
	
	_player = on
	_player.add_child.call_deferred(self)


#region Animations
## Plays appearing animation of the suit
func appear(duration: float = 1.0) -> void:
	animation.play(&"appear")
	await get_tree().create_timer(duration, false).timeout
	animation.play(&"RESET")
#endregion


#region Shapes
## Controls the shape
func switch_shape(shape_state: StringName) -> void:
	if !shape_state in shapes_list:
		return
	
	for i in shapes_list:
		if i == shape_state:
			continue
		for j: NodePath in shapes_list[i]:
			var false_shape := get_node_or_null(j) as CollisionShape2D
			if false_shape:
				false_shape.set_deferred(&"disabled", true)
	
	for k: NodePath in shapes_list[shape_state]:
		var true_shape := get_node_or_null(k) as CollisionShape2D
		if true_shape:
			true_shape.set_deferred(&"disabled", false)
#endregion


#region Setters & Getters
## Returns the [Mario2D] linking to this suit
func get_player() -> Mario2D:
	return _player if is_instance_valid(_player) else null
#endregion
