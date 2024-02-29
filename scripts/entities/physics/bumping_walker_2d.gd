class_name BumpingWalker2D extends Walker2D

## [Walker2D] with capability to bounce and bump.
##
## This node will collide with other bodies and bounce, when [signal bumped] will be emitted with a parameter in type of [KinematicCollision2D] that provides information about the collision.

signal bumped(collision: KinematicCollision2D) ## Emitted when the body bumps on the body
signal bump_called ## Emitted when [method bump] is called.
signal bumped_over ## Emitted when [bouncing_times] reaches zero.

## Rest bouncing times. If it reaches zero, the collision with other ones will be disabled
@export_range(0, 20) var bouncing_times: int = 3:
	set(value):
		bouncing_times = value
		if bouncing_times <= 0:
			collision_mask = 0
			bumped_over.emit()
@export_group("Bouncing")
## When reflect mode is on, the relative axis of velocality will be reflected rather than setting it the related compoennt of [member bouncing_velocality].[br]
## [br]
## For example, if [code]X Reflect[/code] is checked, [code]velocality.x[/code] will be [code]-velocality.x[/code] instead of [code]signf(velocality.x) * bouncing_velocality.x[/code], and the same goes for Y Reflect on [code]velocality.y[/code].
@export_flags("X Reflect", "Y Reflect") var reflect_mode: int
## [EntityBody2D.velocality] in reversed direction on bumping.[br]
## [br]
## If the bumper hits the ceiling, then no velocality.y will be assigned.[br]
## [br]
## See [member reflect_mode] as well for velocality reflection.
@export var bouncing_velocality: Vector2
@export_group("Sounds", "sound_")
@export var sound_bumping: AudioStream = preload("res://assets/sounds/stun.wav")


func _physics_process(delta: float) -> void:
	super(delta)
	
	var is_bumped: bool = false
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		if !collision:
			continue
		bumped.emit(collision)
		is_bumped = true
	
	if is_bumped:
		bump()


func bump() -> void:
	Sound.play_2d(sound_bumping, self)
	
	# X bouncing
	if reflect_mode & 1:
		turn_wall()
	else:
		velocality.x = signf(velocality.x) * -bouncing_velocality.x
	
	# Y bouncing
	if !is_on_ceiling():
		if (reflect_mode >> 1) & 1:
			turn_ceiling_ground()
		else:
			velocality.y = signf(velocality.y) * -bouncing_velocality.y
	
	# Reduces bouncing times
	if bouncing_times > 0:
		bouncing_times -= 1
	
	bump_called.emit()
