class_name AreaDetectingComponent extends Component

## Abstract [Component] that provides exception list for [Area2D]s, so that you
## can add these [Area2D]s for detection exceptions

@export_category("Area Detecting Component")
## The areas in this list will not be detected.
## Useful when a body have two or more [Area2D]s that one shouldn't
## detect the other one(s).
@export var ignored_areas: Array[Area2D]


## Returns [code]true[/code] if the given [parma area] is in the [member ignored_areas]
func is_area_ignored(area: Area2D) -> bool:
	return area in ignored_areas


func get_root() -> Area2D:
	var root := get_node_or_null(root_path) as Area2D
	return root if is_instance_valid(root) else null
