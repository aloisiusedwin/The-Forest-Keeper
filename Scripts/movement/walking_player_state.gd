class_name WalkingPlayerState

extends PlayerMovementState

@export var SPEED: float = 5.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25

func enter(previous_state) -> void:
	if ANIMATION.is_playing() and ANIMATION.current_animation == "JumpEnd":
		await ANIMATION.animation_finished

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta, SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Global.player.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")
	
	if Input.is_action_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	
	if Input.is_action_just_pressed("sprint") and Global.player.is_on_floor():
		transition.emit("SprintingPlayerState")
		
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
		
	if PLAYER.velocity.y < 0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
		