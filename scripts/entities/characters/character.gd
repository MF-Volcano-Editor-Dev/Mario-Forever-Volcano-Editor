class_name Character extends EntityBody2D

## Abstract class that provides basic information of a character
##
## This class only provides [member id] that is necessary for each character. In general situation, you can regard this class as a codical group of characters, which helps provide type hints so that it can improve your development efficiency a bit.

@export_range(0, 3) var id: int
