class_name TagsObject extends Resource

## Resource used for providing tags as extra information to pass to other objects.
##
##

@export_category("Tags Object")
## Preset tags for the tags object
@export var preset_tags: Dictionary:
	set(value):
		_tags = preset_tags
		preset_tags.clear()
		preset_tags.make_read_only()

var _tags: Dictionary


func _init(tags: Dictionary = {}) -> void:
	_tags = tags


#region == Tags handlings ==
## Sets a tag with [param value].[br]
## If the tag [param name] doesn't exist, then creates a new one in the tags list with the name and the [param value].
func set_tag(name: StringName, value: Variant) -> void:
	_tags.merge({name: value})

## Returns the tag [param name] and its value(if existing) or the [param default value](if not existing).
func get_tag(name: StringName, default_value: Variant = null) -> Variant:
	if name in _tags:
		return _tags[name]
	else:
		return default_value

## Removes a tag [param name] from the tags list
func remove_tag(name: StringName):
	_tags.erase(name)

## Adds multiple tags to the tags list
func add_tags(tags: Dictionary) -> void:
	_tags.merge(tags)

## Removes multiple tags from the tags list
func remove_tags(tags: Array[StringName]) -> void:
	for i: StringName in tags:
		remove_tag(i)
#endregion
