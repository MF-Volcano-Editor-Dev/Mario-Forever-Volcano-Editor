class_name BlockHitter extends Component


func _ready() -> void:
	if !_root is Area2D:
		return
	_root.area_entered.connect(_on_hitting_block)


func _on_hitting_block(block_detector: Area2D) -> void:
	if disabled || block_detector:
		return
