class_name WeaponManager
extends Node3D

@export var allow_shoot : bool = true

@export var current_weapon : WeaponResource :
	set(v):
		if v != current_weapon:
			if current_weapon:
				current_weapon.is_equipped = false
			current_weapon = v;
			if is_inside_tree():
				update_weapon_model()
@export var equipped_weapons : Array[WeaponResource]

var current_weapon_view_model : Node3D
var current_weapon_world_model : Node3D

@export var player : CharacterBody3D
@export var bullet_raycast : RayCast3D

@export var view_model_container : Node3D
@export var world_model_container : Node3D

var current_weapon_view_model_muzzle : Node3D

@onready var audio_stream_player = $AudioStreamPlayer3D

func update_weapon_model() -> void:
	if current_weapon_view_model != null and is_instance_valid(current_weapon_view_model):
		current_weapon_view_model.queue_free()
		current_weapon_view_model.get_parent().remove_child(current_weapon_view_model)
	if current_weapon_world_model != null and is_instance_valid(current_weapon_world_model):
		current_weapon_world_model.queue_free()
		current_weapon_world_model.get_parent().remove_child(current_weapon_world_model)
	if current_weapon:
		current_weapon.weapon_manager = self
		if view_model_container and current_weapon.view_model:
			current_weapon_view_model = current_weapon.view_model.instantiate()
			view_model_container.add_child(current_weapon_view_model)
			current_weapon_view_model.position = current_weapon.view_model_pos
			current_weapon_view_model.rotation = current_weapon.view_model_rot
			current_weapon_view_model.scale = current_weapon.view_model_scale
			if current_weapon_view_model.get_node_or_null("AnimationPlayer"):
				current_weapon_view_model.get_node_or_null("AnimationPlayer").connect("current_animation_changed", current_anim_changed)
		if world_model_container and current_weapon.world_model:
			current_weapon_world_model = current_weapon.world_model.instantiate()
			world_model_container.add_child(current_weapon_world_model)
			current_weapon_world_model.position = current_weapon.world_model_pos
			current_weapon_world_model.rotation = current_weapon.world_model_rot
			current_weapon_world_model.scale = current_weapon.world_model_scale
		current_weapon.is_equipped = true
	current_weapon_view_model_muzzle = view_model_container.find_child("MuzzlePlace", true, false) if current_weapon_view_model else null

func play_sound(sound : AudioStream):
	if sound:
		if audio_stream_player.stream != sound:
			audio_stream_player.stream = sound
		audio_stream_player.play()

func stop_sounds():
	audio_stream_player.stop()

var last_played_anim : String = ""
var current_anim_finished_callback
var current_anim_cancelled_callback
func play_anim(name : String, finished_callback = null, cancelled_callback = null):
	var anim_player : AnimationPlayer = current_weapon_view_model.get_node_or_null("AnimationPlayer")
	
	if last_played_anim and get_anim() == last_played_anim and current_anim_cancelled_callback is Callable:
		current_anim_cancelled_callback.call() # Last anim didn't finish yet
	
	if not anim_player or not anim_player.has_animation(name):
		if finished_callback is Callable:
			finished_callback.call() # Treat empty animations as finishing immediately
		return
	
	current_anim_finished_callback = finished_callback
	current_anim_cancelled_callback = cancelled_callback
	last_played_anim = name
	anim_player.clear_queue()
	anim_player.seek(0.0)
	anim_player.play(name)

func queue_anim(name : String):
	var anim_player : AnimationPlayer = current_weapon_view_model.get_node_or_null("AnimationPlayer")
	if not anim_player: return
	anim_player.queue(name)
	
func current_anim_changed(new_anim : StringName):
	var anim_player : AnimationPlayer = current_weapon_view_model.get_node_or_null("AnimationPlayer")
	if new_anim != last_played_anim and current_anim_finished_callback is Callable:
		current_anim_finished_callback.call()
	last_played_anim = anim_player.current_animation
	if last_played_anim != anim_player.current_animation:
		current_anim_finished_callback = null
		current_anim_cancelled_callback = null

func get_anim() -> String:
	var anim_player : AnimationPlayer = current_weapon_view_model.get_node_or_null("AnimationPlayer")
	if not anim_player: return ""
	return anim_player.current_animation

func show_muzzle_flash():
	$ViewMuzzleFlash.emitting = true

func make_bullet_trail(target_pos : Vector3):
	if current_weapon_view_model_muzzle == null:
		return
	var muzzle = current_weapon_view_model_muzzle
	var bullet_dir = (target_pos - muzzle.global_position).normalized()
	var start_pos = muzzle.global_position + bullet_dir * 0.25
	
	if (target_pos - start_pos).length() > 3.0:
		var bullet_tracer = preload("res://controllers/weapon_manager/muzzleflash/bullet_tracer.tscn").instantiate()
		player.add_sibling(bullet_tracer)
		bullet_tracer.global_position = start_pos
		bullet_tracer.target_pos = target_pos
		bullet_tracer.look_at(target_pos)

func _unhandled_input(event):
	if current_weapon and is_inside_tree():
		if event.is_action_pressed("attack") and allow_shoot:
			print("Trigger down")
			current_weapon.trigger_down = true
		elif event.is_action_released("attack"):
			print("NOT Trigger down")
			current_weapon.trigger_down = false
		
		if event.is_action_pressed("reload"):
			current_weapon.reload_pressed()

func _ready() -> void:
	var pistol = load("res://controllers/weapon_manager/Weapon/Pistol/pistol.tres") as WeaponResource
	var amanremu = load("res://controllers/weapon_manager/Weapon/Amanremu/amanremu.tres") as WeaponResource
	var scene_name = get_tree().current_scene.name
	if scene_name == "Forest" || scene_name == "Pabrik" :
		equipped_weapons.append(amanremu)
	
	update_weapon_model()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_weapon:
		current_weapon.on_process(delta)
	if current_weapon_view_model_muzzle:
		$ViewMuzzleFlash.global_position = current_weapon_view_model_muzzle.global_position
