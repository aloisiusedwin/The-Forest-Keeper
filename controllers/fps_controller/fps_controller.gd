class_name Player
extends CharacterBody3D
@export var ANIMATIONPLAYER : AnimationPlayer

#Health
var max_hp = 100
var current_hp = 100
@export var regen_delay : float = 5.0
@export var regen_rate : float = 20.0
@export var damage_taken : float = 0.0
var last_hit_taken : float = 0.0
var is_regen_active : bool = false
var hp_percentage
var red_alpha

#camera
@export var TILT_LOWER_LIMIT := deg_to_rad(-40.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(60.0)
@onready var CAMERA_CONTROLLER : Camera3D = $Head/Camera3D
@onready var head = $Head
@onready var camera = $Head/Camera3D

@onready var hit_rect = $HitUI/ColorRect

#movement
@export var TOGGLE_CROUCH : bool = true
@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D
@export_range(5,10, 0.1) var CROUCH_ANIMATION_SPEED : float = 7.0
const SENSITIVITY = 0.2 # Change only the second float

var gravity = 12.0
var air_time = 0.0
var fall_multiplier = 2.0

const hit_stagger = 8.0

#headbob
const BOB_FREQUENCY = 2.0 #how often footsteps happen
const BOB_AMP = 0.08 #how far camera go when bobbing
var t_bob = 0.0
var disable_headbob: bool = false

#fov
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

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
	current_hp = max_hp

func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * SENSITIVITY
		_tilt_input = -event.relative.y * SENSITIVITY

func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	
func update_camera(delta) -> void:
	_current_rotation = _rotation_input
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQUENCY) * BOB_AMP
	pos.x = cos(time * BOB_FREQUENCY/2) * BOB_AMP
	return pos

func _process(delta: float) -> void:
	regen_hp(delta)

func _physics_process(delta: float) -> void:
	if is_on_floor():
		air_time = 0.0
	else:
		air_time += delta
	
	update_camera(delta)
	Global.debug.add_property("Velocity","%.2f" % velocity.length(), 1)
		
	#headbob
	if !disable_headbob:
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, velocity.length() * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

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

func hit(dir, damage):
	velocity += dir * 8.0
	damage_taken = damage
	current_hp -= damage_taken
	last_hit_taken = 0.0
	is_regen_active = false
	
	if current_hp <= 0:
		die()
	update_hit_effect()

func regen_hp(delta):
	if !is_regen_active:
		last_hit_taken += delta
		if last_hit_taken >= regen_delay:
			is_regen_active = true
	
	if is_regen_active and current_hp < max_hp:
		update_hit_effect()
		current_hp += regen_rate * delta
		if current_hp > max_hp:
			current_hp = max_hp

func update_hit_effect():
	if current_hp < 100:
		hit_rect.visible = true
	else:
		hit_rect.visible = false
		
	hp_percentage = float(current_hp) / max_hp
	red_alpha = lerp(0.0, 0.4, 1.0 - hp_percentage) 
	hit_rect.modulate = Color(1.0, 0.2, 0.2, red_alpha)
	
func die():
	print("ded")
	get_tree().reload_current_scene()