@tool
class_name AutoScrollCamera2D extends GameCamera2D

@export_node_path("PathFollow2D") var camera_follower_path: NodePath = ^".."

@onready var camera_follower: PathFollow2D = get_node_or_null(camera_follower_path) as PathFollow2D


#region == Property Overriders ==
func _property_can_revert(property: StringName) -> bool:
	super(property)
	match property:
		&"focus_characters":
			return false
	return false

func _property_get_revert(property: StringName) -> Variant:
	super(property)
	match property:
		&"focus_characters":
			return false
	return

func _init_overridden_properties() -> void:
	super()
	focus_characters = false
#endregion


#region == Setgets ==
func set_focus_characters(value: bool) -> void:
	if value:
		push_warning("AutoScrollCamera2D shouldn't get this value turned on! See the documentation of GameCamera2D.")
	focus_characters = false
#endregion
