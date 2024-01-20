@icon("res://icons/character_entity_2d.svg")
class_name Character extends EntityBody2D

## Abstract class of controllable characters
##
## This class provides [member id] that is necessary for each character. In general situation, you can regard this class as a codical group of characters, which helps provide type hints so that it can improve your development efficiency a bit.[br]
## To get the character(s) with condition or not, it also provides [Character.CharacterGetter] got by calling [method get_character_getter], which contains several methods that allow you to get the character(s) by such way(s).
## [br]
## [b]Note:[/b] To make the [Character.CharacterGetter] work, you must set the character to the group [i]character[/i].

## Id of the character.[br]
## [br]
## [b]Note:[/b] Each character has different ids, and the characters with the same id will be considered as the same character and lead to problems.
@export_range(0, 3) var id: int
@export_group("Physics", "physics_")
@export_enum("Left:-1", "Right:1") var direction: int = 1:
	set(value):
		direction = value
		if !direction: # No zero direction
			direction = [-1, 1].pick_random()


#region == Getters ==
## Returns an [param action] with [member id].[br]
## E.g.: If an [param action] is [code]&"jump"[/code] and the [member id] is 0, the returned value is to be [code]&"jump0"[/code].[br]
## [b]Tip:[/b] This is very useful when other scripts have to get access to the control status of the character.
func get_input_identifier(action: StringName) -> StringName:
	return action + str(id)

## Returns [code]true[/code] if the [param action] processed by [method get_input_identifier] is pressed.[br]
## This means that if you pass in an [param action] named [code]&"jump"[/code] and the [member id] is 0, this method is actually to detect if the action [code]&"jump0"[/code] is pressed.
func get_input_pressed(action: StringName) -> bool:
	return Input.is_action_pressed(get_input_identifier(action))

## Similar to [method get_input_pressed], but only the first time the key is pressed can this method returns [code]true[/code],
## while a [code]false[/code] is to be returned if the player keeps holding that action.
func get_input_just_pressed(action: StringName) -> bool:
	return Input.is_action_just_pressed(get_input_identifier(action))

## Similar to [method get_input_pressed], but only when the key gets released from being held can this method returns [code]true[/code];
## otherwise a [code]false[/code] is to be returned.
func get_input_just_released(action: StringName) -> bool:
	return Input.is_action_just_released(get_input_identifier(action))

## Returns a [Vector2i] which records the direction of four actions: [param left], [param right], [param up], and [param down].[br]
## [br]
## [b]Note:[/b] The [i]X[/i] component of the vector is left(-1) or right(1), while the [i]Y[/i] component signs up(-1) or down(1).
func get_udlr_directions(left: StringName, right: StringName, up: StringName, down: StringName) -> Vector2i:
	return Vector2i(
		Input.get_vector(
			get_input_identifier(left),
			get_input_identifier(right),
			get_input_identifier(up),
			get_input_identifier(down),
		).round()
	)
#endregion


## A subclass that allows you to get characters.
##
## [b]Note:[/b] The getters in this subclass are required to be passed in a param of [SceneTree] type. So if the caller is a node, then the param can be [method get_tree].
class Getter:
	## Returns an [Array] with [Character]s.
	static func get_characters(scene_tree: SceneTree) -> Array[Character]:
		var result: Array[Character] = []
		for i in scene_tree.get_nodes_in_group(&"character"):
			if i is Character:
				result.append(i)
		return result
	
	## Returns a character with given [param character_id]. See [member Character.id].
	static func get_character(scene_tree: SceneTree, character_id: int) -> Character:
		var characters := get_characters(scene_tree)
		for i in characters:
			if i.id != character_id:
				continue
			return i
		return null
	
	## Returns a character nearest to [param to_gpos].
	static func get_nearest(scene_tree: SceneTree, to_gpos: Vector2) -> Character:
		var characters := get_characters(scene_tree)
		var distances: Array[float] = [] # The packed array doesn't support max() nor min()
		for i in characters:
			distances.append(i.global_position.distance_squared_to(to_gpos))
		return characters[distances.find(distances.min())]
	
	## Returns a character farest from [param to_gpos].
	static func get_farest(scene_tree: SceneTree, to_gpos: Vector2) -> Character:
		var characters := get_characters(scene_tree)
		var distances: Array[float] = [] # The packed array doesn't support max() nor min()
		for i in characters:
			distances.append(i.global_position.distance_squared_to(to_gpos))
		return characters[distances.find(distances.max())]
	
	## Returns character(s) by random [param amount].
	static func get_random(scene_tree: SceneTree, amount: int) -> Array[Character]:
		var characters := get_characters(scene_tree)
		var result: Array[Character] = []
		for i in amount:
			result.append(characters.pop_at(characters.size() - 1))
		return result
