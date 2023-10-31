extends Component

enum Options {
	NONE,
	NORMALIZED
}

@export var accordance_node: Node
@export_group("Accordances")
@export var scale_x_accordance: String
@export var scale_y_accordance: String
@export_group("Options")
@export var scale_x_options: Options = Options.NORMALIZED
@export var scale_y_options: Options = Options.NORMALIZED

var _scale: Vector2 = Vector2.ONE
var _scale_acc_prev: Vector2
var _scale_acc_curr: Vector2


func _ready() -> void:
	super()
	
	if !root is Node2D:
		return
	
	_scale = root.scale


func _process(_delta: float) -> void:
	var xy := [
		accordance_node.get_indexed(scale_x_accordance),
		accordance_node.get_indexed(scale_y_accordance)
	]
	
	for i in 2:
		if xy[i] is float:
			_scale_acc_prev[i] = xy[i]
	for j in 2:
		if _scale_acc_curr[j] != _scale_acc_prev[j]:
			_scale_acc_curr[j] = _scale_acc_prev[j]
			root.scale[j] = _scale[j] * _get_operated_value(j, _scale_acc_curr[j])

func _get_operated_value(column: int, input: float) -> float:
	if column == 0:
		match scale_x_options:
			Options.NORMALIZED:
				return signf(input)
	elif column == 1:
		match scale_y_accordance:
			Options.NORMALIZED:
				return signf(input)
	return input
