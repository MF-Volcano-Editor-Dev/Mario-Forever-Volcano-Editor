extends Node2D

## Emitted when the coin is ready [br]
## [b]Note:[/b] DO NOT connect the [signal Node.ready] directly to the methods in the editor,
## which would cause unexpected crashes
signal coin_hit_ready

## Emitted when the coin hit starts falling
signal coin_hit_started_falling

@export_category("Coin Hit")
@export var speed_y: float = -500
@export var gravity: float = 1250
@export_group("Sounds", "sound_")
@export var sound_coin: AudioStream = preload("res://assets/sounds/coin.wav")


func _ready() -> void:
	_on_item_hit_out(Vector2.ZERO)


func _process(delta: float) -> void:
	speed_y += gravity * delta
	move_local_y(speed_y * delta)
	
	if speed_y > 0:
		coin_hit_started_falling.emit()


func _on_item_hit_out(hitting_direction: Vector2) -> void:
	Sound.play_sound_2d(self, sound_coin)
	
	if hitting_direction:
		global_rotation += hitting_direction.rotated(PI/2).angle()
	
	coin_hit_ready.emit()
