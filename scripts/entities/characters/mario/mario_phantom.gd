extends PhantomGenerator

@export_node_path("MarioPowerup") var powerup_path: NodePath = ^".."
@export var generate_on_floor: bool

@onready var _powerup: MarioPowerup = get_node(powerup_path)


func _process(_delta: float) -> void:
	if root is Mario:
		enabled = (generate_on_floor == root.is_on_floor()) && root.get_current_powerup() == _powerup
