class_name JumpingPlayerState
extends PlayerMovementState

@export var SPEED: float = 5.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var JUMP_VELOCITY: float = 6.0
@export_range(0.5,1.0,0.01) var INPUT_MULTIPLIER: float = 0.85

func enter(previous_state) -> void:
	PLAYER.velocity.y += JUMP_VELOCITY
	ANIMATION.play("JumpStart")
	
func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta, SPEED * INPUT_MULTIPLIER, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if PLAYER.velocity.y < 0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
		
	if PLAYER.is_on_floor():
		ANIMATION.play("JumpEnd")
		if Input.is_action_pressed("sprint"):
			transition.emit("SprintingPlayerState")
		else: 
			transition.emit("IdlePlayerState")
		
