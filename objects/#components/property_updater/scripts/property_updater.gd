extends Component

## Class that stores selected properties from the [member root]
## and make the component monitor them and update them by calling relative methods
##

## Properties to be monitored and updated [br]
## [b]Note:[/b] The key of this dictionary should be a [NodePath] in [String]-type [br]
## For example:
## [codeblock]
## "position" | x: 0
##            | y: 0
## ------------------------
## "scale:x"  | 0
## [/codeblock]
@export_category("Property Updater")
@export var properties: Dictionary

var _properties: Dictionary


func _ready() -> void:
	super()
	
	if !is_instance_valid(root):
		return
	
	extract_properties_from_root()


## Updates the linked properties in [member root] to the values 
## extracted by [method extract_properties_from_root]
func update_from_extracted_value() -> void:
	if !is_instance_valid(root):
		return
	
	for i in _properties:
		root.set_indexed(i, _properties[i])


## Updates the linked properties in [member root] to the values
## from the [member properties]
func update_from_component() -> void:
	if !is_instance_valid(root):
		return
	
	for i in properties:
		root.set_indexed(i, properties[i])


## Extract the properties according to [member properties],
## which will affect the result of [method update_from_extracted_value]
func extract_properties_from_root() -> void:
	for i in properties:
		if !i in root:
			continue
		_properties.merge({i: root[i]})
