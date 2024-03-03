class_name PhantomGenerator extends Component2D

## Used to create multiple [Sprite2D]s to simulate phantom effect.
##
##

## Path to an [AnimatedSprite2D]
@export_node_path("AnimatedSprite2D") var animated_sprite_path: NodePath
## If [code]true[/code], the component can instantiate the phantom
@export var enabled: bool = true
## Duration of the phantom
@export_range(0, 10, 0.001, "suffix:s") var duration: float = 0.5
## Interval of creating phantom
@export_range(0, 5, 0.001, "suffix:s") var interval: float = 0.08

@onready var _animated_sprite: AnimatedSprite2D = get_node(animated_sprite_path)


func _ready() -> void:
	create_tween().set_loops().tween_callback(func() -> void:
		if !enabled:
			return
		
		var spr := Sprite2D.new()
		spr.light_mask = light_mask
		spr.visibility_layer = visibility_layer
		spr.global_transform = global_transform
		
		if _animated_sprite.sprite_frames:
			spr.texture = _animated_sprite.sprite_frames.get_frame_texture(_animated_sprite.animation, _animated_sprite.frame)
		
		root.add_sibling.call_deferred(spr)
		root.get_parent().move_child.call_deferred(spr, root.get_index() - 1)
		
		(func() -> void:
			var tw: Tween = spr.create_tween()
			tw.tween_property(spr, ^"modulate:a", 0, duration)
			tw.finished.connect(spr.queue_free)
		).call_deferred()
	).set_delay(interval)
