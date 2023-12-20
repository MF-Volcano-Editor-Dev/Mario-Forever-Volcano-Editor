@static_unload
class_name Checkpoint extends Classes.HiddenArea2D

@export_category("Check Point")
@export_range(0, 1, 1, "or_greater") var id: int

static var touched_ids: PackedInt32Array
static var last_cp: int
