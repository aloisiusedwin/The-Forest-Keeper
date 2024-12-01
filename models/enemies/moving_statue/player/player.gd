class_name PlayerR
extends CharacterBody3D

@export var VIDEOPLAYER : VideoStreamPlayer
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var mouse_sensitivity = 0.15 / (get_viewport().get_visible_rect().size.x/1152.0)
@onready var cam = $Head/Camera3D

#Flashlight
@export_group("TORCH PARAMETERS")
@export var click_audios: Array[AudioStream]
@onready var camera_holder : Node3D = get_node(NodePath("Head"))

@export var can_use_torch : bool = true
@onready var torchloc : Node3D = get_node(NodePath("Head/TorchHolder/Torchloc"))
@onready var torch : Node3D = get_node(NodePath("Head/TorchHolder/Torch"))
@onready var torch_light : Node3D = get_node(NodePath("Head/TorchHolder/Torch/TorchLight"))
@onready var torch_timer : Timer = get_node(NodePath("Timers/TorchTimer"))
@onready var torch_click_sfx : AudioStreamPlayer3D = get_node(NodePath("PlayerAudios/TorchClickSfx"))
@export var torch_sway_speed : float = 15.0

func random_torch_click() -> AudioStream:
	return click_audios[randi() % click_audios.size()]

signal stepped
func _step(_is_on_floor:bool) -> bool:
	if (is_on_floor):
		emit_signal("stepped")
		return true
	return false

func _ready():
	play_cutscene()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

signal video_finished
@onready var cutscenecanvas = $Cutscene
@export var stop_input : bool = false

func play_cutscene():
	VIDEOPLAYER.stream = preload("res://Video/level 2.ogv")
	
	if VIDEOPLAYER.stream:
		stop_input = true
		VIDEOPLAYER.play()
	
func _on_video_finished() -> void:
	cutscenecanvas.visible = false
	stop_input = false

func _physics_process(delta):
	if stop_input:
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		var input_dir = Input.get_vector("left", "right", "up", "down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		torch.global_transform.origin = torchloc.global_transform.origin
		torch.rotation.y = lerp_angle(torch.rotation.y, rotation.y, torch_sway_speed * delta)
		torch.rotation.x = lerp_angle(torch.rotation.x, cam.rotation.x, torch_sway_speed * delta)

		move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y += event.relative.x * -mouse_sensitivity
		cam.rotation_degrees.x += event.relative.y * -mouse_sensitivity
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
	
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
