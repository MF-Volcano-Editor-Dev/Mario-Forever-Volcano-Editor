class_name CharactersManager2D

## Static class used to manage characters' data, getting, etc.

static var _characters_data_list: CharactersDataList2D = CharactersDataList2D.new()
static var _characters_getter: CharactersGetter2D = CharactersGetter2D.new()
static var _characters_data_getter: CharactersDataGetter2D = CharactersDataGetter2D.new()

## A subclass of [CharactersManager] resorted to manage the data of characters
class CharactersDataList2D:
	var _data_list: Dictionary # Data list
	
	
	## Register a data of [param character] into the list
	func register(character: CharacterEntity2D, override: bool = true) -> void:
		var data := CharacterDataStorage2D.new(character)
		_data_list.merge({character.id: data}, override)
	
	
	## Returns the data of a character with given [param id]
	func get_data(id: int) -> CharacterDataStorage2D:
		if !id in _data_list:
			return null
		return _data_list[id] as CharacterDataStorage2D
	
	## Returns data list of all characters
	func get_all_data_list() -> Dictionary:
		return _data_list
	
	
	## Unregister the data of a character with given [param id]
	func unregister(id: int) -> void:
		if !id in _data_list:
			return
		_data_list.erase(id)
	
	## Unregister the data of all characters
	func unregister_all() -> void:
		_data_list.clear()
	
	
	## Class used to store the data of a character
	class CharacterDataStorage2D:
		var _character: CharacterEntity2D
		var _global_transform: Transform2D
		var _power_id: StringName
		
		
		func _init(character: CharacterEntity2D) -> void:
			_character = character
			_global_transform = character.global_transform
			_power_id = character.power_id
		
		
		## Returns current character
		func get_character() -> CharacterEntity2D:
			return _character if is_instance_valid(_character) else null
		
		## Returns the global transform of the current character
		func get_global_transform() -> Transform2D:
			return _global_transform
		
		## Returns [member CharacterEntity2D.power_id] of the current character
		func get_power_id() -> StringName:
			return _power_id


## A Subclass used to get characters
##
## [b]Note:[/b] Almost all functions in this class are [b][u]coroutines with [code]await[/code] as a prefix before calling the methods[/u][/b]
## and [u]must be called with a parameter typed [SceneTree][/u]. This is coded to ensure that the tree is 
## ready so that the function can be safely called by every node in every time. Otherwise, e.g., if there
## is a node calling a method to get players while the players, who are registered in [method Node._ready], are going to be ready
## right after the caller node, an error will be thrown saying that the function "is trying to call an method on a Nil object".
class CharactersGetter2D:
	## Returns all available characters [br]
	## [b]Note:[/b] When [method SceneTree.change_scene_to_file] or [method SceneTree.change_scene_to_packed] is called,
	## this will return an empty array, so please make sure that it is called during the procession of the tree
	func get_characters(tree: SceneTree) -> Array[CharacterEntity2D]:
		# Await readiness of the current scene to ensure all players
		# can be safely got
		await Process.await_current_scene_readiness(tree)
		
		const Storage := CharactersDataList2D.CharacterDataStorage2D # Reference in shorter spelling
		
		var rst: Array[CharacterEntity2D] = []
		var data := CharactersManager2D.get_characters_data_list().get_all_data_list() # Get all characters' data
		for i in data: # Iterate 
			var storage: = data[i] as Storage # Trys to cast the storage to Storage and makes it nullize if failing casting
			if !storage:
				continue # Skip if the storage is null
			
			var character := storage.get_character() # Same as the above one, but for character
			if !is_instance_valid(character):
				continue # Skip if the character is null (invalid)
			
			rst.append(character) # Append a valid character into the result array
		
		return rst
	
	## Returns a character with the minimum of id
	func get_character_with_id_min(tree: SceneTree) -> CharacterEntity2D:
		await Process.await_current_scene_readiness(tree)
		
		const Storage := CharactersDataList2D.CharacterDataStorage2D

		var player_data := CharactersManager2D.get_characters_data_list().get_all_data_list() # Here we load the list to avoid double for-loops that could consumes CPU performance
		if player_data.is_empty():
			return null

		var player_ids: Array[int] = []
		for i: int in player_data: # Iterate the data list here, if we referred to get_characters(), then double for-loops will happen, which is a bit costy
			player_ids.append(i)
		
		return (player_data[player_ids.min()] as Storage).get_character()

	## Returns a character with the maximum of id
	func get_character_with_id_max(tree: SceneTree) -> CharacterEntity2D:
		await Process.await_current_scene_readiness(tree)
		
		const Storage := CharactersDataList2D.CharacterDataStorage2D

		var player_data := CharactersManager2D.get_characters_data_list().get_all_data_list()
		if player_data.is_empty():
			return null

		var player_ids: Array[int] = []
		for i: int in player_data:
			player_ids.append(i)
		
		return (player_data[player_ids.max()] as Storage).get_character()
	
	## Returns a character nearest to [param global_position]
	func get_character_nearest_to(tree: SceneTree, global_position: Vector2) -> CharacterEntity2D:
		var characters := await get_characters(tree) # It's more convenient to get all characters here, though double for-loops exists here
		if characters.is_empty():
			return null
		
		var arr_dis: Array[Vector2] = []
		for i: CharacterEntity2D in characters:
			arr_dis.append(i.global_position.distance_squared_to(global_position))
		
		return characters[arr_dis.find(arr_dis.min())]
	
	## Returns a character farest to [param global_position]
	func get_character_farest_to(tree: SceneTree, global_position: Vector2) -> CharacterEntity2D:
		var characters := await get_characters(tree)
		if characters.is_empty():
			return null
		
		var arr_dis: Array[Vector2] = []
		for i: CharacterEntity2D in characters:
			arr_dis.append(i.global_position.distance_squared_to(global_position))
		
		return characters[arr_dis.find(arr_dis.max())]


## A subclass used to get data of players
## [b]Note:[/b] This is different from [CharactersManager2D.CharactersDataList2D] because this subclass puts more focus on
## getting information like average global position of all players and so on.
class CharactersDataGetter2D:
	## Returns average global positin of valid players
	func get_average_global_position(tree: SceneTree, fallback: Vector2) -> Vector2:
		var characters := await CharactersManager2D.get_characters_getter().get_characters(tree)
		if characters.is_empty():
			return fallback

		var gpos := Vector2.ZERO
		for i: CharacterEntity2D in characters:
			gpos += i.global_position
		
		return gpos / float(characters.size())
	


#region == Getters ==
## Returns [CharactersManager2D.CharactersDataList2D]
static func get_characters_data_list() -> CharactersDataList2D:
	return _characters_data_list

## Returns [CharactersManager2D.CharactersGetter2D]
static func get_characters_getter() -> CharactersGetter2D:
	return _characters_getter

## Returns [CharactersManager2D.CharactersDataGetter2D]
static func get_character_data_getter() -> CharactersDataGetter2D:
	return _characters_data_getter
#endregion
