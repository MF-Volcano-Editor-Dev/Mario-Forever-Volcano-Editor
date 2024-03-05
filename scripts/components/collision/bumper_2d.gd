class_name Bumper2D extends ShapeCast2D

## A collision caster used to activate [BumpBlock2D]
##
##

## Path to the body to be passed in [method BumpBlock2D.bump]
@export_node_path("Node2D") var body_path: NodePath = ^".."

## Body of the caster, see [member body_path]
@onready var body: Node2D = get_node(body_path)


func _physics_process(_delta: float) -> void:
	for i in get_collision_count():
		var col := get_collider(i)
		if col is BumpBlock2D:
			col.bump(self, get_collision_point(i))
