class_name SprintingPlayerState

extends PlayerMovementState

@export var SPEED: float = 8.5
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25

func enter(previous_state) -> void:
	pass

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta, SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("sprint"):
		transition.emit("WalkingPlayerState")
		
	if Input.is_action_just_pressed("crouch") and PLAYER.velocity.length() > 7:
		transition.emit("SlidingPlayerState")
