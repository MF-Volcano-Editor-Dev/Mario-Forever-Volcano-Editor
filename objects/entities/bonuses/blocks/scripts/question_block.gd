extends Classes.HittableBlock

## Emitted when an item is hit out
signal hit_out(item: Node2D, item_component: Component)

## Emitted when the [member items] is empty [b] during the procession of [method hit]
signal hit_to_empty

## Emitted when items are inserted
signal item_inserted

## Emitted when the [member items] is empty [br]
## It is recommended to connect this signal with functions such as animation playing, visibility switching, etc.
signal item_empty

@export_category("Question Block")
## Items in the block [br]
## [b]Caution!:[/b] It's [color=red]NOT ALLOWED[/code] to change this property; instead, if you
## want to insert new items, please call [method insert_item]
@export var items: Array[BonusBlockItem]
@export_group("Sounds", "sound_")

var _amount: int


func _ready() -> void:
	_clear_invalid_items()
	_test_empty()


## Makes the block got hit, and if no items in the block,
## the sprite (AnimatedSprite2D) will play [b]"done"[/b] animation
func hit(by_area: Area2D) -> void:
	# Restore transparency
	if transparent:
		restore_from_transparency()
		hit_animation(by_area)
		_test_empty()
	
	# Remove invalid items
	
	
	if _test_empty():
		return
	
	hit_animation(by_area)
	
	var it := items[0].item.instantiate()
	add_sibling(it)
	
	_amount += 1
	if _amount >= items[0].amount:
		_amount = 0 # Restore the amount count
		items.pop_front() # Erase the first element
	
	# If no items after the hit, emits the signal
	if _test_empty():
		hit_to_empty.emit()


## Insert items into the [member item]
func insert_item(item: BonusBlockItem) -> void:
	if !item:
		return
	
	items.append(item)
	item_inserted.emit()
	_clear_invalid_items()


# Checks if the items is empty and emits [signal item_empty] if empty
func _test_empty() -> bool:
	if !items.is_empty():
		return false
	
	item_empty.emit()
	return true


# Checks if `items` has invalid items and remove them if they are
func _clear_invalid_items() -> void:
	for i: BonusBlockItem in items:
		if i != null && i.item && i.item.get_state().get_node_count():
			continue
		items.erase(i)
