extends Component

@export var beetroot: EntityBody2D

@onready var attacker: Classes.Attacker = $"../Attacker"
@onready var block_hitter: Classes.BlockHitter = $"../BlockHitter"



func _ready() -> void:
	super()
	
	if !root is Area2D:
		return
	
	root.area_entered.connect(_on_area_fluid.bind(true))
	root.area_exited.connect(_on_area_fluid.bind(false))


func _on_area_fluid(area: Area2D, is_entering: bool) -> void:
	if !beetroot:
		return
	
	if area is AreaFluid2D && &"beetroot_sinkable" in area.fluid_features:
		beetroot.speed = 0
		beetroot.velocity.x = 0
		
		if is_entering:
			attacker.disabled = true
			block_hitter.disabled = true
		else:
			attacker.disabled = false
			block_hitter.disabled = false
