extends ItemWalker2D

@export_category("Entity Carrier")
## Entity to be carried
@export var entity: PackedScene
## Display of the entity
@export var display: Texture2D
@export_group("References")
## Path to a [Sprite2D] to draw the [member display]
@export_node_path("Sprite2D") var sprite_path: NodePath = ^"Sprite2D"

@onready var _sprite: Sprite2D = get_node(sprite_path)


func _ready() -> void:
	velocality.x = 1
	
	super()
	
	_sprite.texture = display
	_sprite.flip_h = velocality.x < 0
	
	velocality.x = 0
	
	started_movement.connect(func() -> void:
		if entity:
			var ins: Node2D = entity.instantiate()
			ins.global_transform = global_transform
			add_sibling.call_deferred(ins)
		
		queue_free()
	)
