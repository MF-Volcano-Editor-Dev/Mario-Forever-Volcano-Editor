extends Component

@export_category("Mario Block Hitter Limitator")
@export var mario: Mario2D


func _process(_delta: float) -> void:
	if !mario || !root is Classes.BlockHitter:
		return
	root.disabled = !mario.is_leaving_ground()
