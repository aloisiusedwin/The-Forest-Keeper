class_name FallingPlayerState
extends PlayerMovementState

@export var SPEED: float = 6.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25

func enter(previous_state) -> void:
	ANIMATION.pause()

func exit() -> void:
	pass

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta, SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
		
	if PLAYER.is_on_floor():
		ANIMATION.play("JumpEnd")
		transition.emit("IdlePlayerState")
