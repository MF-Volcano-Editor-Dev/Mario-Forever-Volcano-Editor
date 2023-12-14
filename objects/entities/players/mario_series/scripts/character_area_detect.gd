class_name CharacterAreaDetect2D extends Component

@warning_ignore("unused_private_class_variable")
var _areas_by_body: Array[Area2D]:
	set = _areas_by_body_updated
@warning_ignore("unused_private_class_variable")
var _areas_by_head: Array[Area2D]:
	set = _areas_by_head_updated

@onready var _power := get_parent() as CharacterPower2D
@onready var _character := get_character() as CharacterEntity2D
@onready var _flagger := _character.get_flagger() as Flagger
@onready var _body := _character.get_detector_body() as Area2D
@onready var _head := _character.get_detector_head() as Area2D


func _ready() -> void:
	_body.area_entered.connect(_on_area_body_detected.bind(true))
	_body.area_exited.connect(_on_area_body_detected.bind(false))
	_head.area_entered.connect(_on_area_head_detected.bind(true))
	_head.area_exited.connect(_on_area_head_detected.bind(false))


#region == Area entering & exiting ==
func _on_area_body_detected(area: Area2D, in_or_out: bool) -> void:
	if is_inactive():
		return
	if in_or_out && !area in _areas_by_body:
		_areas_by_body.append(area)
	elif !in_or_out && area in _areas_by_body:
		_areas_by_body.erase(area)
	_areas_by_body = _areas_by_body # Triggers setter

func _on_area_head_detected(area: Area2D, in_or_out: bool) -> void:
	if is_inactive():
		return
	if in_or_out && !area in _areas_by_head:
		_areas_by_head.append(area)
	elif !in_or_out && area in _areas_by_head:
		_areas_by_head.erase(area)
	_areas_by_head = _areas_by_head # Triggers setter


func _areas_by_body_updated(rest_areas: Array[Area2D]) -> void:
	if is_inactive():
		return
	# Index 0, for AreaFluid
	# Index 1, for climbable areas
	var counts: PackedInt32Array = [0, 0]
	for i: Area2D in rest_areas:
		if i is AreaFluid2D && i.character_swimmable: # Swimmable
			counts[0] += 1
			_flagger.set_flag(&"is_swimming", true)
		if i.is_in_group(&"%%climbable"): # Climable
			counts[1] += 1
	_flagger.set_flag(&"is_swimming", counts[0] > 0)
	_flagger.set_flag(&"is_climbable", counts[1] > 0)
	if !counts[1]:
		_flagger.set_flag(&"is_climbing", false)

func _areas_by_head_updated(rest_areas: Array[Area2D]) -> void:
	if is_inactive():
		return
	# Index 0, for swimming out
	var counts: PackedInt32Array = [0]
	for i: Area2D in rest_areas:
		if i is AreaFluid2D && i.character_swimmable:
			counts[0] += 1
	_flagger.set_flag(&"is_swimming_out", counts[0] <= 0)
#endregion

#region == Getters ==
func is_inactive() -> bool:
	return disabled || _power.process_mode == PROCESS_MODE_DISABLED

func get_power() -> CharacterPower2D:
	return get_root() as CharacterPower2D

func get_character() -> CharacterEntity2D:
	return _power.get_parent() as CharacterEntity2D
#endregion
