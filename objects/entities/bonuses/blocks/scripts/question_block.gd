extends Classes.HittableBlock

## Emitted when an item is hit out
signal hit_out(item: Node2D, item_component: Component)

## Emitted when items are inserted
signal item_inserted

## Emitted when the [member items] is empty during the hitting process
signal item_empty

@export_category("Question Block")
## Items in the block [br]
## [b]Caution!:[/b] It's [color=red]NOT ALLOWED[/code] to change this property; instead, if you
## want to insert new items, please call [method insert_item]
@export var items: Array[BonusBlockItem]
@export_group("Sounds", "sound_")
@export var sound_player: Sound2D
@export var sound_hit: AudioStream

var _amount: int


## Makes the block got hit, and if no items in the block,
## the sprite (AnimatedSprite2D) will play [b]"done"[/b] animation
func hit(by_area: Area2D) -> void:
	var empty := items.is_empty()
	
	# Restore transparency
	if transparent:
		restore_from_transparency()
		hit_animation(by_area)
		# If there is no items initially, then emit a signal
		if empty:
			item_empty.emit()
	
	# Block execution if no items
	if empty:
		return
	
	hit_animation(by_area)
	
	var it := items[0].item.instantiate()
	add_sibling(it)
	
	_amount += 1
	if _amount >= items[0].amount:
		_amount = 0 # Restore the amount count
		items.pop_front() # Erase the first element
	
	# If no items after the hit, emits the signal
	if items.is_empty():
		item_empty.emit()


## Insert items into the [member item]
func insert_item(item: BonusBlockItem) -> void:
	if !item:
		return
	items.append(item)
	item_inserted.emit()
