class_name EnemyKillingProcess2D extends Instantiater2D

## Used together with [Attackee] to provide instances creation for it.[br]
## [br]
## This component will instantiate objects based on [member root]. When a character stomps on
## [br]
## [b]Note 1:[/b] This works only when [signal Attackee.on_hit_by_attacker] is connected to [killing_process].[br]
## [b]Note 2:[/b] You need to and can only add [u]two[/u] [Node2D]s under this component as its children nodes. One should be named as "Success" while the other one as "Defense".

signal killing_processed ## Emitted when the killing is processed.
signal killing_succeeded ## Emitted when the killing process is successful.
signal killing_defended ## Emitted when the killing process is defended.


## Called to process killing and instantiate relevant objects.[br]
## [br]
## [b]Note:[/b] Please connect [signal EnemyStompable.on_stomp_succeeded] to this call.
func killing_process(attacker: Attacker) -> void:
	killing_processed.emit()
	
	if attacker:
		instantiate_child(&"Success")
		killing_succeeded.emit()
	else:
		instantiate_child(&"Defense")
		killing_defended.emit()
