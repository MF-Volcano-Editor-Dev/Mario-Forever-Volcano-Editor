extends Classes.HittableBlock

## Emitted when the bricks gets hit, but not broken
signal biricks_got_hit(by_area: Area2D)

## Emitted when the bricks gets broken
signal bricks_broken

@export_category("Bricks")
@export_range(0, 20, 1, "or_greater", "suffix:times") var breaks_times: int = 1
@export_group("Broken")
@export var broken_scraps: PackedScene = preload("res://objects/entities/#effects/scraps/scrap_bricks.tscn")
@export var broken_scraps_offset: PackedVector2Array = [
	Vector2(8, 8),
	Vector2(8, -8),
	Vector2(-8, -8),
	Vector2(-8, 8),
]
@export var broken_scraps_velocity: PackedVector2Array = [
	Vector2(200, -350),
	Vector2(100, -400),
	Vector2(-100, -400),
	Vector2(-200, -350),
]
@export_group("Sounds", "sound_")
@export var sound_mario_bump: AudioStream = preload("res://assets/sounds/bump.wav")
@export var sound_broken: AudioStream = preload("res://assets/sounds/break.wav")


func bricks_breaks(by_area: Area2D, hitter: Classes.BlockHitter) -> void:
	if !&"bricks_breaker" in hitter.hitter_features:
		return
	
	var obj := by_area.get_parent()
	var breakable := true
	
	# For Mario2D, check if the curren suit allows the character to break
	# the bricks
	if obj is Mario2D:
		var suit: Classes.MarioSuit2D = obj.get_suit()
		if !suit || &"bricks_unbreakable" in suit.suit_features:
			breakable = false
	
	if breakable:
		breaks_times -= 1
		if breaks_times <= 0:
			bricks_broken.emit()
			return
		else:
			breakable = false
	
	if !breakable:
		Sound.play_sound_2d(self, sound_mario_bump)
		biricks_got_hit.emit(by_area)


func bricks_scraps(sound: bool = true) -> void:
	if !broken_scraps:
		return
	
	if sound:
		Sound.play_sound_2d(self, sound_broken)
	
	var scrps: Array[EntityBody2D] = []
	for i in broken_scraps_offset.size():
		var scrp := broken_scraps.instantiate() as EntityBody2D
		if !scrp:
			scrp.queue_free()
		scrps.append(scrp)
	for j in scrps.size():
		var scrp := scrps[j]
		add_sibling.call_deferred(scrp)
		scrp.global_transform = global_transform.translated_local(broken_scraps_offset[j])
		scrp.global_velocity = broken_scraps_velocity[j].rotated(global_rotation)
