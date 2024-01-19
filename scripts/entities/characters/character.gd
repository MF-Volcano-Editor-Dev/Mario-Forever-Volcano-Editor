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
