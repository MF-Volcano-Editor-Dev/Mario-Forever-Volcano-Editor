class_name Walker2D extends EntityBody2D

## A type of physics body that walks, containing a property to set initial facing direction.
##
## This body will automatically move in [method Node._physics_process], and if you override the virtual method, remember to add a [code]super()[/code] before or after the execution of your own codes in that function.[br]
## [br]
## Meanwhile, the body allows you to set its initial direction in three modes. See [enum InitDirection] for details.

## Methods determining the walking direction on the readiness of the body.
enum InitDirection {
	BY_VELOCITY, ## Default option. The body will move as the value of [member EntityBody2D.velocality].x, which means that a minus value forces the body to move left while a positive value forces it to move right.
	LOOK_AT_PLAYER, ## The body will move towards the player initially.
	BACK_TO_PLAYER ## The body will move backwards to the player initially.
}

## Initial walking direction. See [enum InitDirection] for details.
@export var initial_direction: InitDirection = InitDirection.BY_VELOCITY


func _ready() -> void:
	initialize_direction.call_deferred() # Called in a deferred manner to ensure the direction will be correctly set no matter where the node is in the scene tree


func _physics_process(delta: float) -> void:
	move_and_slide()


## Initializes the moving direction of the object.
func initialize_direction() -> void:
	var np := Character.Getter.get_nearest(get_tree(), global_position) # Nearest player
	if !np:
		if initial_direction != InitDirection.BY_VELOCITY:
			velocality.x *= [-1, 1].pick_random() # Random direction if no player is in the level
		return
	
	velocality.x *= Transform2DAlgo.get_direction_to_regardless_transform(global_position, np.global_position, global_transform)
