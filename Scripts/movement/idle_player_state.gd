class_name IdlePlayerState

extends PlayerMovementState

@export var SPEED: float = 5.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25

func enter(previous_state) -> void:
	if ANIMATION.is_playing() and ANIMATION.current_animation == "JumpEnd":
		await ANIMATION.animation_finished
		ANIMATION.pause()
	else:
		ANIMATION.pause()

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta, SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if PLAYER.is_on_floor():
		if Input.is_action_pressed("crouch"):
			transition.emit("CrouchingPlayerState")
			
		elif Input.is_action_just_pressed("jump"):
			transition.emit("JumpingPlayerState")
			
	if Global.player.velocity.length() > 0.0 and Global.player.is_on_floor():
		if Input.is_action_pressed("sprint"):
			transition.emit("SprintingPlayerState")
		else:
			transition.emit("WalkingPlayerState")

	if PLAYER.velocity.y < 0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
