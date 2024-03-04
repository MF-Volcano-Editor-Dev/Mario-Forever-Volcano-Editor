class_name ItemWalker2D extends Walker2D

## A [Walker2D] for items hit from [BumpBlock2D].
##
##

## Speed of rising
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var rising_speed: float = 25
@export_group("References")
## Path to the effect box that may contain the collision behavior of the item.
@export_node_path("Area2D") var effect_box_path: NodePath
@export_group("Sounds", "sound_")
@export var sound_hit: AudioStream = preload("res://assets/sounds/appear.wav")

var _rising_dir: int


func _physics_process(delta: float) -> void:
	if _rising_dir:
		var del := rising_speed * _rising_dir * delta
		move_local_y(del, false)
		# Restore behaviors
		if !test_move(global_transform, Vector2.ZERO, null, 0):
			_rising_dir = 0
			initialize_direction.call_deferred()
			
			var effect_box: Area2D = get_node_or_null(effect_box_path) as Area2D
			if effect_box:
				for i in effect_box.get_shape_owners():
					effect_box.shape_owner_set_disabled.call_deferred(i, false)
	else:
		super(delta)

## Called by [BumpBlock2D].
## @deprecated
func hit(block: BumpBlock2D) -> void:
	Sound.play_2d(sound_hit, self)
	
	var effect_box: Area2D = get_node_or_null(effect_box_path) as Area2D
	if effect_box:
		for i in effect_box.get_shape_owners():
			effect_box.shape_owner_set_disabled(i, true)
	
	_rising_dir = -1 if block.get_dot_to_up() > cos(deg_to_rad(block.tolerance)) else 1
