class_name BonusBlockItem extends Resource

## Item to be stored and initiated by a bonus block
@export var item: PackedScene
## Amount of the item
@export_range(1, 10000, 1, "or_greater", "prefix:x") var amount: int = 1:
	set(value):
		amount = clampi(value, 0, 10000)
## The icon that you want the bonus block to show
@export var preview: Texture2D
