class_name PlayerR
extends CharacterBody3D

@export var VIDEOPLAYER : VideoStreamPlayer
@export var AUDIOPLAYER : AudioStreamPlayer

@onready var heartbeat = $heartbeat
@onready var flanker1 = $"../../MovingStatue"
@onready var flanker2 = $"../../MovingStatue2"
var distance_to_closest_flanker = 9999.3
var normalized_distance = 1.0

const MIN_PITCH: float = 0.9  # Pitch minimum
const MAX_PITCH: float = 1.25  # Pitch maksimum
const MIN_DISTANCE: float = 2.0  # Jarak minimum untuk pitch minimum
const MAX_DISTANCE: float = 12.0  # Jarak maksimum untuk pitch maksimum

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
	heartbeat.play()
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

var stop = Engine.time_scale

##DEBUG GAMING
#var debug_timer : float = 0.0
#const debug_interval : float = 1.0

func _physics_process(delta):
	#debug_timer += delta
	#if debug_timer >= debug_interval:
		#print("flanker1 : " + str(flanker1.triggered))
		#print("flanker2 : " + str(flanker2.triggered))
		#print("flanker1 distance : " + str(flanker1.distance_to_target))
		#print("flanker2 distance : " + str(flanker2.distance_to_target))
		#print("distance closest : " + str(distance_to_closest_flanker))
		#debug_timer = 0.0
	
	if flanker1.triggered:
		distance_to_closest_flanker = flanker1.distance_to_target
	elif flanker2.triggered:
		distance_to_closest_flanker = flanker2.distance_to_target
	
	if distance_to_closest_flanker != 9999.3:
		normalized_distance = clamp((distance_to_closest_flanker - MIN_DISTANCE) / (MAX_DISTANCE - MIN_DISTANCE), 0.0, 1.0)
	heartbeat.pitch_scale = lerp(MAX_PITCH, MIN_PITCH, normalized_distance)
	heartbeat.set_volume_db(linear_to_db(1 - normalized_distance))
	stop = Engine.time_scale
	if caught:
		if !VIDEOPLAYER.is_playing():
			get_tree().change_scene_to_file("res://Scenes/Dead Menu/dead_menu.tscn")
			
	if stop_input:
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

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

var caught = false

func _input(event):
	if stop == 0:
		return
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
	
func _on_escaped_body_entered(body: Node3D) -> void:
	# Defer the scene change to happen after the physics callback
	call_deferred("_change_scene")
	
func _change_scene() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level/Pabrik/Pabrik.tscn")
	
func _on_player_caught() -> void:
	caught = true
	cutscenecanvas.visible = true
	VIDEOPLAYER.stream = preload("res://Video/jumpscare.ogv")
	AUDIOPLAYER.play()
	get_tree().create_timer(1.0).timeout
	if VIDEOPLAYER.stream:
		stop_input = true
		VIDEOPLAYER.play()
		emit_signal("video_finished")
	
