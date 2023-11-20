extends Component

## Emitted when the solid detection succeeds and both solid bodies are face-to-face
signal detected_solid_body

@export_category("Solid Detector")
@export var solid_group: StringName


func _ready() -> void:
	super()
	
	if !root is Area2D:
		return
	
	root.area_entered.connect(_body_solid_detect)


func _body_solid_detect(area: Area2D) -> void:
	if area == root:
		return
	
	for i: Node in area.get_children():
		if i == self:
			continue
		elif i is Classes.SolidDetector && i.solid_group == solid_group:
			detected_solid_body.emit()
			break
