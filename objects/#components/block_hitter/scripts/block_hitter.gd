extends Component

## Emitted when the body hits a hittable block
signal hit_block(block: Classes.HittableBlock)

@export_category("Block Hitter")
## Hitter's types
@export var hitter_targets: Array[StringName]
## Features of the hitter
@export var hitter_features: Array[StringName]
## From which direction can be detected by a hitable block
@export_flags("Bottom", "Sides", "Top") var hittable_directions_from: int = 0b111
@export_group("Hitting Direction")


func _ready() -> void:
	super()
	
	if !root is Area2D:
		return
	
	root.area_entered.connect(_on_hit_hittable_block)


func _on_hit_hittable_block(area: Area2D) -> void:
	if disabled:
		return
	
	var block := area.get_parent()
	if block is Classes.HittableBlock:
		block.block_got_hit(root, self, hittable_directions_from)
		hit_block.emit(block)
