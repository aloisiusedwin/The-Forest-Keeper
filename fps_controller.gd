extends CharacterBody3D

@export_range(5,10, 0.1) var CROUCH_ANIMATION_SPEED : float = 7.0
@export var TOGGLE_CROUCH : bool = true
@export var ANIMATIONPLAYER : AnimationPlayer
@export var CROUCH_SHAPECAST : Node3D


#movement
var speed
const CROUCH_SPEED = 2.0
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.5
const JUMP_VELOCITY = 6
const SENSITIVITY = 0.001 * 1.2 # Change only the second float

var _is_crouching : bool = false

#headbob
const BOB_FREQUENCY = 2.0 #how often footsteps happen
const BOB_AMP = 0.08 #how far camera go when bobbing
var t_bob = 0.0

#fov
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	
	Global.player = self
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#add crouch check shapecast collision exception for CharacterBody3D node
	CROUCH_SHAPECAST.add_exception($".")

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y (-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _input(event):
	if event.is_action_pressed("crouch") and is_on_floor() and TOGGLE_CROUCH == true:
		toggle_crouch()
	if event.is_action_pressed("crouch") and _is_crouching == false and is_on_floor() and TOGGLE_CROUCH == false:
		crouching(true) #Hold to crouch
	if event.is_action_released("crouch") and TOGGLE_CROUCH == false:
		if CROUCH_SHAPECAST.is_colliding() == false:
			crouching(false) #Release to uncrouch
		elif CROUCH_SHAPECAST.is_colliding() == true:
			uncrouch_check()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQUENCY) * BOB_AMP
	pos.x = cos(time * BOB_FREQUENCY/2) * BOB_AMP
	return pos

func _physics_process(delta: float) -> void:
	
	Global.debug.add_property("MovementSpeed", speed, 1)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and _is_crouching == false:
		velocity.y = JUMP_VELOCITY

	#Sprint Walk check
	if Input.is_action_pressed("sprint") and _is_crouching == false:
		speed = SPRINT_SPEED
	elif _is_crouching:
		speed = CROUCH_SPEED
	else:
		speed = WALK_SPEED
		
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			#velocity.x = lerp(velocity.x, direction.x * speed, delta * 8.0)
			#velocity.z = lerp(velocity.z, direction.z * speed, delta * 8.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.5)
		velocity.y = lerp(velocity.y, direction.y * speed, delta * 2.5)
	#headbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func toggle_crouch():
	if _is_crouching == true and CROUCH_SHAPECAST.is_colliding() == false:
		crouching(false)
	elif _is_crouching == false:
		crouching(true)

func crouching(state : bool):
	match state:
		true:
			ANIMATIONPLAYER.play("Crouch", 0, CROUCH_ANIMATION_SPEED)
		false:
			ANIMATIONPLAYER.play("Crouch", 0, -CROUCH_ANIMATION_SPEED, true)

func uncrouch_check():
	if CROUCH_SHAPECAST.is_colliding() == false:
		crouching(false)
	if CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch_check()

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "Crouch":
		_is_crouching = !_is_crouching
