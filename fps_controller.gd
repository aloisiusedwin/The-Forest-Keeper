class_name Player

extends CharacterBody3D

@export var ANIMATIONPLAYER : AnimationPlayer

#camera
@export var TILT_LOWER_LIMIT := deg_to_rad(-40.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(60.0)
@onready var CAMERA_CONTROLLER : Camera3D = $Head/Camera3D
@onready var head = $Head
@onready var camera = $Head/Camera3D

#movement
@export var TOGGLE_CROUCH : bool = true
@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D
@export_range(5,10, 0.1) var CROUCH_ANIMATION_SPEED : float = 7.0
const SENSITIVITY = 0.2 # Change only the second float
var gravity = 12.0

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

func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * SENSITIVITY
		_tilt_input = -event.relative.y * SENSITIVITY

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
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

func _physics_process(delta: float) -> void:
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

#PISTOL MECHANISM
#signal update_ammo
#@onready var ANIMATIONPISTOL = $WeaponViewport/SubViewport/Camera3D/Pistol/AnimationPlayer
#@onready var gun_barrel = $WeaponViewport/SubViewport/Camera3D/Pistol/RayCast3D
#var bullet = load("res://models/weapons/pistol/bullet.tscn")
#var instance
#
##pistol ammo
#var currentammo = 12
#var reserveammo = 12
#var magazine = 12
#var maxammo = 36
#
#func _process(delta: float) -> void:
	#if !ANIMATIONPISTOL.is_playing():
		#if Input.is_action_just_pressed("attack"):
			#shoot()
		#if Input.is_action_just_pressed("reload"):
			#reload()
#
#func shoot():
	#if currentammo != 0:
		#ANIMATIONPISTOL.speed_scale = 3.0
		#ANIMATIONPISTOL.play("PistolArmature|Fire")
		#
		#instance = bullet.instantiate()
		#instance.position = gun_barrel.global_position
		#instance.transform.basis = gun_barrel.global_transform.basis
		#get_parent().add_child(instance)
		#currentammo -= 1
		#await ANIMATIONPISTOL.animation_finished
		#ANIMATIONPISTOL.speed_scale = 1.0
		#emit_signal("update_ammo", currentammo, reserveammo)
	#else:
		#reload()
#
#func reload():
	#if currentammo == magazine:
		#return
	#elif reserveammo != 0:
		#ANIMATIONPISTOL.play("PistolArmature|Reload")
		#await ANIMATIONPISTOL.animation_finished
		#ANIMATIONPISTOL.play("PistolArmature|Slide")
		#await ANIMATIONPISTOL.animation_finished
		#var reloadammount = min(magazine - currentammo, magazine, reserveammo)
		#currentammo = currentammo + reloadammount
		#reserveammo = reserveammo - reloadammount
		#emit_signal("update_ammo", currentammo, reserveammo)
		#
		#
