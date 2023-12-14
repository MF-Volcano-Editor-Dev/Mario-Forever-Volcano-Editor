class_name Effects extends Component

## A component class that stores effects from [Effect2D]
##
## This component is used to be connected with signals from the editor pannel.

signal effect_over ## Emitted when the effect is over

@onready var _root := get_root() as Node2D


#region == Effects ==
func transparentize(duration: float) -> void:
	if disabled || !_root:
		return
	await Effects2D.transparentize(_root, duration).finished
	effect_over.emit()

func transparentize_slide(duration: float, height: float = 48, delay_to_transparent: float = 1, ease_in_or_out: bool = false) -> void:
	if disabled || !_root:
		return
	await Effects2D.transparentize_slide(_root, duration, height, delay_to_transparent, ease_in_or_out).finished
	effect_over.emit()

func slime(duration: float, height: float, reverse: bool = false) -> void:
	if disabled || !_root:
		return
	await Effects2D.slime(_root, duration, height, reverse).finished
	effect_over.emit()

func flash(duration: float, interval: float = 0.08) -> void:
	if disabled || !_root:
		return
	await Effects2D.flash(_root, duration, interval).finished
	effect_over.emit()

func swirl_down(duration: float, to_angle: float, random_direction: bool = true) -> void:
	if disabled || !_root:
		return
	await Effects2D.swirl_down(_root, duration, to_angle, random_direction).finished
	effect_over.emit()

func swirl_and_transparentize(duration: float, to_angle: float, random_direction: bool = true) -> void:
	if disabled || !_root:
		return
	await Effects2D.swirl_and_transparentize(_root, duration, to_angle, random_direction).finished
	effect_over.emit()
#endregion
