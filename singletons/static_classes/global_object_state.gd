class_name ObjectState

## Static class used to manage state of an object
##
## [b]Note:[/b] This system runs based on metadata with prefix &"stt", so make sure there is no metadata pre-set beginning with
## this

const _STATE_PREFIX := &"stt"

## Sets the state of an object
static func set_state(object: Object, state: StringName, value: bool) -> void:
    if !is_instance_valid(object):
        return
    object.set_meta(_STATE_PREFIX + state, value)

## Sets multiple states of an object
static func set_multistates(object: Object, states: Array[StringName], values: Array[bool]) -> void:
    for i in states.size():
        set_state(object, states[i], values[i])

## Returns the state of an object, if the state inexists, then returns [code]false[/code] by default
static func is_state(object: Object, state: StringName) -> bool:
    if !is_instance_valid(object):
        return false
    return bool(object.get_meta(_STATE_PREFIX + state, false))

## Returns [code] true if all given states are true
static func is_multistates_all_true(object: Object, states: Array[StringName]) -> bool:
    var rst := 0
    for i: StringName in states:
        rst &= int(is_state(object, i))
    return bool(rst)

## Returns [code] true if one of the given states are true
static func is_multistates_one_true(object: Object, states: Array[StringName]) -> bool:
    var rst := 0
    for i: StringName in states:
        rst |= int(is_state(object, i))
    return bool(rst)

## Removes a state from an object
static func remove_state(object: Object, state: StringName) -> void:
    if !is_instance_valid(object):
        return
    object.remove_meta(_STATE_PREFIX + state)