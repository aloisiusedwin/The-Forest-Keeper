class_name CrouchingPlayerState

extends PlayerMovementState

@export var SPEED: float = 2.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25

@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D
@export_range(5,10, 0.1) var CROUCH_ANIMATION_SPEED : float = 7.0

var RELEASED : bool = false

func enter(previous_state) -> void:
	ANIMATION.speed_scale = 1.0
	if previous_state.name != "SlidingPlayerState":
		ANIMATION.play("Crouch", -1.0, CROUCH_ANIMATION_SPEED)
	elif previous_state.name == "SlidingPlayerState":
		ANIMATION.current_animation = "Crouch"
		ANIMATION.seek(1.0, true)

func exit() -> void:
	RELEASED = false

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta, SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("crouch"):
		uncrouch()
	elif Input.is_action_pressed("crouch") == false and !RELEASED:
		RELEASED = true
		uncrouch()
		
func uncrouch():
	if CROUCH_SHAPECAST.is_colliding() == false:
		ANIMATION.play("Crouch", -1.0, -CROUCH_ANIMATION_SPEED, true)
		await ANIMATION.animation_finished
		if PLAYER.velocity.length() == 0:
			transition.emit("IdlePlayerState")
		else:
			transition.emit("WalkingPlayerState")
			
	elif CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch()
		
