class_name QuestionBlock2D extends BumpBlock2D

## A kind of bumpable block which may provide items by getting hit.
##
## This requires items to be categorized in the node group named [code]item[/code], and move them under this node to become its children nodes.[br]
## [br]
## [b]Note:[/b] Do NOT rescale this object, and be careful to rotate it, because all items will be created with the same [member Node2D.global_transform] as the one of this.

## Fallback if there is no any item as the child node of this object
@export var items: Array[QuestionBlockItem] = [preload("res://objects/entities/bonuses/blocks/question_block_res/q_coin.tres")]
@export_group("References")
## Path to the animated_sprite
@export_node_path("AnimatedSprite2D") var animated_sprite_path: NodePath

@onready var _animated_sprite: AnimatedSprite2D = get_node_or_null(animated_sprite_path)


func _bump_process(bumper: Bumper2D, _touch_spot: Vector2) -> void:
	if !items.is_empty():
		var q_item: PackedScene = items.pop_front().get_item(bumper.body)
		if !q_item:
			return
		
		var i := q_item.instantiate()
		i.global_transform = global_transform
		add_sibling.call_deferred(i)
		get_parent().move_child.call_deferred(i, get_index())
		
		var hit := Callable(i, &"hit")
		if hit.is_valid():
			hit.call_deferred()
	
	if items.is_empty():
		if _animated_sprite:
			_animated_sprite.play(&"hit")
	else:
		restore_bump()
