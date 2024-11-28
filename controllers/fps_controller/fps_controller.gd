class_name Player
extends CharacterBody3D

@export var ANIMATIONPLAYER : AnimationPlayer
@export var VIDEOPLAYER : VideoStreamPlayer
var video_checked : bool = false

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
@export var TILT_LOWER_LIMIT := deg_to_rad(-70.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(60.0)
@onready var CAMERA_CONTROLLER : Camera3D = $Head/Camera3D
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var hit_rect = $PlayerHUD/HitUI/ColorRect

#movement
@export var stop_input : bool = false
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

#Audio
signal stepped
func _step(_is_on_floor:bool) -> bool:
	if (is_on_floor):
		emit_signal("stepped")
		return true
	return false

#Flashlight
@export_group("TORCH PARAMETERS")
@export var click_audios: Array[AudioStream]
@onready var camera_holder : Node3D = get_node(NodePath("Head"))

@export var can_use_torch : bool = false
@onready var torchloc : Node3D = get_node(NodePath("Head/TorchHolder/Torchloc"))
@onready var torch : Node3D = get_node(NodePath("Head/TorchHolder/Torch"))
@onready var torch_light : Node3D = get_node(NodePath("Head/TorchHolder/Torch/TorchLight"))
@onready var torch_timer : Timer = get_node(NodePath("Timers/TorchTimer"))
@onready var torch_click_sfx : AudioStreamPlayer3D = get_node(NodePath("PlayerAudios/TorchClickSfx"))
@export var torch_sway_speed : float = 15.0

func random_torch_click() -> AudioStream:
	return click_audios[randi() % click_audios.size()]

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
	play_cutscene()
	
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
	elif event.is_action_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if can_use_torch:
		if Input.is_action_just_pressed("toggle_torch") and torch_light.visible == false and torch_timer.is_stopped():
			torch_light.show()
			torch_timer.start()
			torch_click_sfx.stream = random_torch_click()
			torch_click_sfx.play()
		elif Input.is_action_just_pressed("toggle_torch") and torch_light.visible == true and torch_timer.is_stopped():
			torch_light.hide()
			torch_timer.start()
			torch_click_sfx.stream = random_torch_click()
			torch_click_sfx.play()
		torch.visible = true
	else :
		torch.visible = false
	
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
	if !video_checked:
		if !VIDEOPLAYER.is_playing():
			emit_signal("video_finished")
			video_checked = true
		
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
	
	torch.global_transform.origin = torchloc.global_transform.origin
	torch.rotation.y = lerp_angle(torch.rotation.y, rotation.y, torch_sway_speed * delta)
	torch.rotation.x = lerp_angle(torch.rotation.x, camera.rotation.x, torch_sway_speed * delta)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, velocity.length() * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

func update_gravity(delta) -> void:
	velocity.y -= (gravity + gravity * air_time * fall_multiplier) * delta

func update_input(delta: float, speed: float, acceleration: float, deceleration: float) -> void:
	if stop_input:
		velocity.x = 0
		velocity.z = 0
		return
		
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
	var scene_name = get_tree().current_scene.name
	if scene_name == "Forest":
		print("ded")
		get_tree().change_scene_to_file("res://Scenes/Level/Rumah/Rumah.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Level/Forest/forest.tscn")

func _on_escaped_body_entered(_body: Node3D) -> void:
	get_tree().change_scene_to_file("res://Scenes/Level/Pabrik/Pabrik.tscn")

signal video_finished
@onready var cutscenecanvas = $Cutscene

func play_cutscene():
	var scene_name = get_tree().current_scene.name
	if scene_name == "Forest":
		VIDEOPLAYER.stream = preload("res://Video/level1.ogv")
	elif scene_name == "Rumah":
		VIDEOPLAYER.stream = preload("res://Video/level 2.ogv")
	elif scene_name == "Pabrik":
		VIDEOPLAYER.stream = preload("res://Video/level 3.ogv")
		
	if VIDEOPLAYER.stream:
		stop_input = true
		VIDEOPLAYER.play()
	
func _on_video_finished() -> void:
	cutscenecanvas.visible = false
	stop_input = false
