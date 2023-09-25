class_name InterfacesList

## A class where you can code your own interfaces here
## 
## If you donwloaded the system via git cloning, then it's better to list your interfaces here!

# 👇 === Here you can define your own interfaces == 👇 #
class EntityHandler extends Interface:
	func move(_delta: float) -> void: pass
	func jump(_jumping_speed: float) -> void: pass
	func accelerate(_to: Vector2, _acceleration: float, _delta: float) -> void: pass
	func accelerate_x(_to: float, _acceleration: float, _delta: float) -> void: pass
	func accelerate_y(_to: float, _acceleration: float, _delta: float) -> void: pass
	func turn_x() -> void: pass
	func turn_y() -> void: pass
