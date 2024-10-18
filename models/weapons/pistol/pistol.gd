extends Node3D

@onready var  = %AnimationPlayer
@onready var gun_barrel = $"."
var bullet = load("res://models/weapons/pistol/bullet.tscn")
var instance

func _process(delta: float) -> void:
	if !.is_playing():
		if Input.is_action_just_pressed("attack"):
			shoot()
		if Input.is_action_just_pressed("reload"):
			reload()

func shoot():
	.speed_scale = 3.0
	.play("PistolArmature|Fire")
	
	instance = bullet.instantiate()
	instance.position = gun_barrel.global_position
	instance.transform.basis = gun_barrel.global_transform.basis
	get_parent().add_child(instance)
	
	await .animation_finished
	.speed_scale = 1.0

func reload():
	if .has_animation("PistolArmature|Reload"):
		.play("PistolArmature|Reload")
		await .animation_finished
	else:
		print("Animation not found")
