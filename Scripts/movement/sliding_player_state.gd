class_name SlidingPlayerState
extends PlayerMovementState

@export var SPEED: float = 6.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var TILT : float = 0.12

@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D
@export_range(5,10, 0.1) var SLIDE_ANIMATION_SPEED : float = 4.0

func enter(previous_state) -> void:
	set_tilt(PLAYER._current_rotation)
	ANIMATION.get_animation("Sliding").track_set_key_value(5,0, PLAYER.velocity.length())
	ANIMATION.speed_scale = 1.0
	ANIMATION.play("Sliding", -1.0, SLIDE_ANIMATION_SPEED)

func update(delta):
	PLAYER.disable_headbob = true
	PLAYER.update_gravity(delta)
	#PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
func set_tilt(player_rotation) -> void:
	var tilt = Vector3.ZERO
	tilt.z = clamp(TILT * player_rotation, -0.1, 0.1)
	if tilt.z == 0.0:
		tilt.z == 0.05
	ANIMATION.get_animation("Sliding").track_set_key_value(6,0,PLAYER.camera.fov)
	ANIMATION.get_animation("Sliding").track_set_key_value(6,2,PLAYER.camera.fov)
	ANIMATION.get_animation("Sliding").track_set_key_value(3,1,tilt)
	ANIMATION.get_animation("Sliding").track_set_key_value(3,2,tilt)
	
	
func finish():
	PLAYER.disable_headbob = false
	transition.emit("CrouchingPlayerState")
	
