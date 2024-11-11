class_name Player

extends CharacterBody3D

@export var ANIMATIONPLAYER : AnimationPlayer

# Camera settings
@export var TILT_LOWER_LIMIT := deg_to_rad(-40.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(60.0)
@onready var CAMERA_CONTROLLER : Camera3D = $Head/Camera3D
@onready var head = $Head
@onready var camera = $Head/Camera3D

@onready var hit_rect = $HitUI/ColorRect

# Movement and crouching
@export var TOGGLE_CROUCH : bool = true
@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D
@export_range(5,10, 0.1) var CROUCH_ANIMATION_SPEED : float = 7.0
const SENSITIVITY = 0.2
const JOY_SENSITIVITY = 1.0  # Adjust rotation speed for joystick input
const JOY_DEADZONE = 0.1     # Deadzone for joystick input to prevent drift

# Movement speeds
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.5

var gravity = 12.0
var air_time = 0.0
var fall_multiplier = 2.0

const hit_stagger = 8.0

# Headbob
const BOB_FREQUENCY = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0
var disable_headbob: bool = false

# FOV
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Mouse and joystick input variables
var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3
var _current_rotation : float

func _ready():
	CROUCH_SHAPECAST.add_exception($".")
	Global.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	# Mouse input for camera rotation
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * SENSITIVITY
		_tilt_input = -event.relative.y * SENSITIVITY

func _input(event):
	# Check if ESC is pressed to exit the game
	if event.is_action_pressed("ui_cancel"):  # "ui_cancel" is mapped to ESC by default in Godot
		get_tree().quit()

func _physics_process(delta: float) -> void:
	# Joystick input for camera rotation (right stick X-axis and Y-axis)
	var controller_x = Input.get_joy_axis(0, 2)  # Right stick X-axis
	var controller_y = Input.get_joy_axis(0, 3)  # Right stick Y-axis

	# Apply deadzone and sensitivity for joystick input
	if abs(controller_x) > JOY_DEADZONE:
		_rotation_input = -controller_x * JOY_SENSITIVITY
	if abs(controller_y) > JOY_DEADZONE:
		_tilt_input = -controller_y * JOY_SENSITIVITY

	# Update camera based on input
	update_camera(delta)

	# Gravity and movement logic
	if is_on_floor():
		air_time = 0.0
	else:
		air_time += delta

	Global.debug.add_property("Velocity", "%.2f" % velocity.length(), 1)

	# Head bobbing effect
	if !disable_headbob:
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)

	var velocity_clamped = clamp(velocity.length(), 0.5, velocity.length() * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

func update_camera(delta) -> void:
	_current_rotation = _rotation_input
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta

	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)

	CAMERA_CONTROLLER.rotation.z = 0.0

	# Reset inputs after each frame to avoid accumulation
	_rotation_input = 0.0
	_tilt_input = 0.0

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQUENCY) * BOB_AMP
	pos.x = cos(time * BOB_FREQUENCY / 2) * BOB_AMP
	return pos

func update_gravity(delta) -> void:
	velocity.y -= (gravity + gravity * air_time * fall_multiplier) * delta

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

func hit(dir):
	hit_rect.visible = true
	velocity += dir * hit_stagger
	await get_tree().create_timer(0.4).timeout
	hit_rect.visible = false
