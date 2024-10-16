class_name Player

extends CharacterBody3D

@export var ANIMATIONPLAYER : AnimationPlayer

@export var TOGGLE_CROUCH : bool = true
@export var CROUCH_SHAPECAST : Node3D
@export_range(5,10, 0.1) var CROUCH_ANIMATION_SPEED : float = 7.0

#movement
const JUMP_VELOCITY = 6
const SENSITIVITY = 0.001 * 1.2 # Change only the second float
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

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
	#add crouch check shapecast collision exception for CharacterBody3D node
	CROUCH_SHAPECAST.add_exception($".")
	Global.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y (-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQUENCY) * BOB_AMP
	pos.x = cos(time * BOB_FREQUENCY/2) * BOB_AMP
	return pos

func _physics_process(delta: float) -> void:
	
	Global.debug.add_property("Velocity","%.2f" % velocity.length(), 1)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and !Input.is_action_just_pressed("crouch"):
		velocity.y = JUMP_VELOCITY
		
	#headbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, velocity.length() * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

func update_gravity(delta) -> void:
	velocity.y -= gravity * delta
	
func update_input(delta: float, speed: float, acceleration: float, deceleration: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)

	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.5)
		velocity.y = lerp(velocity.y, direction.y * speed, delta * 2.5)
	
func update_velocity() -> void:
	move_and_slide()
