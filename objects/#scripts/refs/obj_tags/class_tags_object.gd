class_name TagsObject

var _tags: Dictionary


func _init(tags: Dictionary = {}) -> void:
	_tags = tags


func set_tag(name: StringName, value: Variant) -> void:
	_tags.merge({name: value})


func get_tag(name: StringName, default_value: Variant = null) -> Variant:
	if name in _tags:
		return _tags[name]
	else:
		return default_value


func add_tags(tags: Dictionary) -> void:
	_tags.merge(tags)


func remove_tags(tags: Array[StringName]) -> void:
	for i: StringName in tags:
		if !i in _tags:
			continue
		_tags.erase(i)
