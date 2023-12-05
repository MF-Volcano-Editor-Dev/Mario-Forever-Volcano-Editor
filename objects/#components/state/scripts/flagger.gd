@icon("res://icons/flagger.svg")
class_name Flagger extends Component

## A components that stores boolean for each custom flags.
##
## Flagger is a container that contains a bunch of booleans with names, and
## manages them via methods.

signal flag_set(flag_name: StringName, value: bool) ## Emitted when a flag is set with [param value]
signal flag_removed(flag_name: StringName) ## Emitted when a flag is removed

@export_category("Flagger")
@export var preset_flags: Dictionary:
	set(value):
		_flags = value
		preset_flags.clear()
		preset_flags.make_read_only()
		for i in _flags:
			if !i is StringName:
				i = StringName(str(i))
			if !_flags[i] is bool:
				_flags[i] = bool(int(clampi(_flags[i], 0, 1)))

var _flags: Dictionary # Stored flags


#region == Flags operations ==
## Sets a flag with its [param value] for the flags list.[br]
## If the flag doesn't exist, a new space will be taken for creating the flag and set its value.
func set_flag(flag_name: StringName, value: bool) -> void:
	if flag_name in _flags && _flags[flag_name] == value:
		return
	_flags[flag_name] = value
	flag_set.emit(flag_name, value)

## Returns the value of the flag.[br]
## If the flag doesn't exist, then returns [code]false[/code]
func is_flag(flag_name: StringName) -> bool:
	return flag_name in _flags && _flags[flag_name]

## Removes a flag from the flags list.
func remove_flag(flag_name: StringName) -> void:
	_flags.erase(flag_name)
	flag_removed.emit(flag_name)

## Sets multiple flags for the flags list. See [method set_flag].
func set_mutiple_flags(flag_names: Array[StringName], values: Array[bool]) -> void:
	for i in flag_names.size():
		set_flag(flag_names[i], values[i])

## If any flag to check is [code]true[/code], then returns [code]true[/code], otherwise [code]false[/code].
func is_multiple_flag_any(flag_names: Array[StringName]) -> bool:
	for i: StringName in flag_names:
		if !i in _flags:
			continue
		elif _flags[i]:
			return true
	return false

## If all flags to check are [code]true[/code], then returns [code]true[/code], otherwise [code]false[/code].
func is_multiple_flag_all(flag_names: Array[StringName]) -> bool:
	for i: StringName in flag_names:
		if !i in _flags || !_flags[i]:
			return false
	return true

## Removes multiple flags from the flags list.
func remove_multiple_flags(flag_names: Array[StringName]) -> void:
	for i: StringName in flag_names:
		remove_flag(i)

## Removes all flags from the list.
func clear_all_flags() -> void:
	_flags.clear()
#endregion
