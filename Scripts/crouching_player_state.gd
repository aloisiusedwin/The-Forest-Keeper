class_name CrouchingPlayerState

extends PlayerMovementState

@export var SPEED: float = 2.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25

@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D
@export_range(5,10, 0.1) var CROUCH_ANIMATION_SPEED : float = 7.0

func enter() -> void:
	ANIMATION.play("Crouch", -1.0, CROUCH_ANIMATION_SPEED)

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta, SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("crouch"):
		uncrouch()
			
func crouching(state : bool):
	match state:
		true:
			ANIMATION.play("Crouch", 0, CROUCH_ANIMATION_SPEED)
		false:
			ANIMATION.play("Crouch", 0, -CROUCH_ANIMATION_SPEED, true)
			if ANIMATION.is_playing():
				await ANIMATION.animation_finished
			transition.emit("IdlePlayerState")

func uncrouch():
	if CROUCH_SHAPECAST.is_colliding() == false and Input.is_action_pressed("crouch") == false:
		ANIMATION.play("Crouch", -1.0, -CROUCH_ANIMATION_SPEED, true)
		if ANIMATION.is_playing():
			await ANIMATION.animation_finished
		transition.emit("IdlePlayerState")
	if CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch()
