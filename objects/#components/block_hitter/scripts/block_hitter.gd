extends Component

@export_category("Block Hitter")
## Hitter's types
@export var hitter_targets: Array[StringName]
## Features of the hitter
@export var hitter_features: Array[StringName]
@export_group("Hitting Direction")


func _ready() -> void:
	super()
	
	if !root is Area2D:
		return
	
	root.area_entered.connect(_on_hit_hittable_block)


func _on_hit_hittable_block(area: Area2D) -> void:
	var block := area.get_parent()
	if block is Classes.HittableBlock:
		var dir: Vector2 = Vector2.ZERO
		
		var body := root.get_parent()
		if body is PhysicsBody2D:
			dir = PhysicsServer2D.body_get_direct_state(body.get_rid()).linear_velocity
		
		block.block_got_hit(root, self, dir.normalized())
