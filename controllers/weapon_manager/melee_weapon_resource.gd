class_name MeleeWeaponResource
extends WeaponResource

@export var max_hit_dist = 1

@export var miss_sound : AudioStream

func shot():
	#weapon_manager.trigger_weapon_shoot_world_anim()
	weapon_manager.play_anim(view_shoot_anim) 
	weapon_manager.queue_anim(view_idle_anim)
	
	var raycast = weapon_manager.bullet_raycast
	raycast.target_position = Vector3(0,0,-abs(max_hit_dist))
	raycast.force_raycast_update()
	
	var bullet_target_pos = raycast.global_transform * raycast.target_position
	if raycast.is_colliding():
		weapon_manager.play_sound(shoot_sound)
		var obj = raycast.get_collider()
		var nrml = raycast.get_collision_normal()
		var pt = raycast.get_collision_point()
		bullet_target_pos = pt
		BulletDecalPool.spawn_bullet_decal(pt, nrml, obj, raycast.global_basis, preload("res://controllers/weapon_manager/decal/knifedecal.png"))
		
		if obj.is_in_group("enemy"):
			#var blood_splatter = preload("res://FPSController/weapon_manager/knife/blood_splatter.tscn").instantiate()
			#obj.add_sibling(blood_splatter)
			#blood_splatter.global_position = pt
			raycast.get_collider().hit(1)
	else:
		weapon_manager.play_sound(miss_sound)
	
	last_fire_time = Time.get_ticks_msec()
