class_name WeaponResource
extends Resource

@export var name : String
@export var icon : Texture2D

@export_range(1,9) var slot : int = 1
@export_range(1,10) var slot_priority : int = 1

@export var view_model : PackedScene
@export var world_model : PackedScene

@export var view_model_pos : Vector3
@export var view_model_rot : Vector3
@export var view_model_scale := Vector3(1, 1, 1)
@export var world_model_pos : Vector3
@export var world_model_rot : Vector3
@export var world_model_scale := Vector3(1, 1, 1)

@export var view_equip_anim : String
@export var view_rack_anim : String
@export var view_shoot_anim : String
@export var view_reload_anim : String
@export var view_idle_anim : String

#SFX
@export var shoot_sound : AudioStream
@export var reload_sound : AudioStream
@export var equip_sound : AudioStream

#Logic
@export var damage = 20
@export var current_ammo = 121212
@export var reserve_ammo = 12
@export var magazine = 12
@export var maxammo = 36

@export var auto_fire : bool = true
@export var fire_rate : float = 4

const raycast_distance : float = 300
var weapon_manager : WeaponManager

var trigger_down := false:
	set(v):
		if trigger_down != v:
			trigger_down = v
			if trigger_down:
				on_trigger_down()
			else:
				on_trigger_up()

func on_trigger_down():
	if Time.get_ticks_msec() - last_fire_time >= fire_rate and current_ammo > 0:
		shot()
	elif current_ammo == 0:
		reload_pressed()

func on_trigger_up():
	pass
 
var is_equipped := false:
	set(v):
		if is_equipped != v:
			is_equipped = v
			if is_equipped:
				on_equip()
			else:
				on_unequip()

func on_equip():
	weapon_manager.play_anim(view_rack_anim)
	
func on_unequip():
	pass

var instance
var last_fire_time = -99999

func on_process(delta):
	if trigger_down and auto_fire and Time.get_ticks_msec() - last_fire_time >= fire_rate:
		if current_ammo > 0:
			shot()
		else:
			reload_pressed()

var shots_fired : int = 0
func shot():
	weapon_manager.play_anim(view_shoot_anim)
	weapon_manager.play_sound(shoot_sound)
	
	var raycast = weapon_manager.bullet_raycast
	raycast.target_position = Vector3(0,0,-abs(raycast_distance))
	raycast.force_raycast_update()
	var bullet_target_pos = raycast.global_transform * raycast.target_position
	
	if raycast.is_colliding():
		var object = raycast.get_collider()
		var normal = raycast.get_collision_normal()
		var point = raycast.get_collision_point()
		bullet_target_pos = point
		if !object.is_in_group("enemy"):
			BulletDecalPool.spawn_bullet_decal(point, normal, object, raycast.global_basis)
		
		if raycast.get_collider().is_in_group("enemy"):
				raycast.get_collider().hit(1)
	
	weapon_manager.show_muzzle_flash()
	if shots_fired % 2 == 0:
		weapon_manager.make_bullet_trail(bullet_target_pos)
	
	last_fire_time = Time.get_ticks_msec()
	current_ammo -= 1
	shots_fired += 1

func get_amount_can_reload() -> int:
	var reloadammount = min(magazine - current_ammo, magazine, reserve_ammo)
	return reloadammount

func reload_pressed():
	if view_reload_anim and weapon_manager.get_anim() == view_reload_anim:
		return
	if get_amount_can_reload() <= 0:
		return
	var cancel_cb = (func():
		weapon_manager.stop_sounds())
		
	weapon_manager.play_anim(view_reload_anim, reload, cancel_cb)
	weapon_manager.queue_anim(view_rack_anim)
	weapon_manager.play_sound(reload_sound)

func reload():
	var reloadammount = get_amount_can_reload()
	current_ammo += reloadammount
	reserve_ammo -= reloadammount
