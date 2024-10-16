class_name CrouchingPlayerState

extends PlayerMovementState

@export var SPEED: float = 2.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25

#@export var TOGGLE_CROUCH : bool = true
@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D
@export_range(5,10, 0.1) var CROUCH_ANIMATION_SPEED : float = 7.0
#var _is_crouching : bool = false

func enter() -> void:
	ANIMATION.play("Crouch", -1.0, CROUCH_ANIMATION_SPEED)

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta, SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("crouch"):
		uncrouch()
			
#func _on_animation_player_animation_started(anim_name: StringName) -> void:
	#if anim_name == "Crouch":
		#_is_crouching = !_is_crouching
		#PLAYER._is_crouching = !PLAYER._is_crouching
#
#func toggle_crouch():
	#if _is_crouching == true and CROUCH_SHAPECAST.is_colliding() == false:
		#crouching(false)
	#elif _is_crouching == false:
		#crouching(true)
#
#func _input(event):
		#if event.is_action_pressed("crouch") and Global.player.is_on_floor() and TOGGLE_CROUCH == true:
			#toggle_crouch()
		#if event.is_action_pressed("crouch") and _is_crouching == false and Global.player.is_on_floor() and TOGGLE_CROUCH == false:
			#crouching(true) #Hold to crouch
		#if event.is_action_released("crouch") and TOGGLE_CROUCH == false:
			#if CROUCH_SHAPECAST.is_colliding() == false:
				#crouching(false) #Release to uncrouch
			#elif CROUCH_SHAPECAST.is_colliding() == true:
				#uncrouch_check()

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
