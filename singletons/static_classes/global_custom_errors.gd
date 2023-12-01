class_name CustomErrors

## Static class that provides functions to show custom errors


## Pushes an error and quit the game if the game is released
static func error_and_quit(content: String) -> void:
	if OS.is_debug_build():
		assert(content)
	else:
		OS.alert(content, "Error Happened!")
		OS.kill(OS.get_process_id())
