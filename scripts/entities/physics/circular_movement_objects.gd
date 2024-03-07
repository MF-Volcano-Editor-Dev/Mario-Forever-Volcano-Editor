extends Node2D

@export_category("Circular Movement Object")
@export_group("Tracks and Speed")
@export_subgroup("Basic")
@export var amplitude: Vector2 = Vector2.ONE * 150
@export_range(-18000, 18000, 0.001, "suffix:°/s") var frequency: float = 50
@export_range(-180, 180, 0.001, "degrees") var phase: float
@export_subgroup("Track Rotation")
@export_range(-18000, 18000, 0.001, "suffix:°/s") var track_rotation_speed: float
@export_range(-180, 180, 0.001, "degrees") var track_angle: float
@export_subgroup("Special Radius")
@export var amplitude_max: Vector2 = Vector2.ONE * 200
@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var radius_changing_speed: float
@export var changing_mode := Tween.TRANS_LINEAR
@export_group("Facing")
@export_enum("Sine", "Cosine", "Look at Player", "Back against Player") var facing_mode: int = 2

var circle: Ellipse = Ellipse.new()


func _ready() -> void:
	circle.amplitude = amplitude
	circle.rotation = deg_to_rad(track_angle)
	circle.center = position

func _physics_process(delta: float) -> void:
	phase = wrapf(phase + frequency * delta, -180, 180)
	track_angle = wrapf(track_angle + track_rotation_speed * delta, -180, 180)
	
	var arc_phase := deg_to_rad(phase)
	
	match facing_mode:
		0:
			set_meta(&"facing", sin(arc_phase))
		1:
			set_meta(&"facing", cos(arc_phase))
		2, 3:
			var np := Character.Getter.get_nearest(get_tree(), global_position)
			if !np:
				return
			set_meta(&"facing", Transform2DAlgo.get_direction_to_regardless_transform(global_position, np.global_position, global_transform) * (1 if facing_mode == 2 else -1))
