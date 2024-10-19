extends Node3D
#
#@onready var ANIMWEAPON = %AnimationPlayer
#
#var current_weapon = null
#var weapon_stack = []
#var weapon_indicator = 0
#var next_weapon : String
#var Weapon_List = {}
#
#@export var _weapon_resource: Array[WeaponResource]
#@export var Start_Weapons : Array[String]
#
#func _ready():
	#Initialize(Start_Weapons)
	#
#func _input(event):
	#if event.is_action_pressed("weapon_up"):
		#weapon_indicator = min(weapon_indicator+1, weapon_stack.size()-1)
		#exit(weapon_stack[weapon_indicator])
		#
	#if event.is_action_pressed("weapon_up"):
		#weapon_indicator = max(weapon_indicator-1, 0)
		#exit(weapon_stack[weapon_indicator])
#
#func Initialize(_start_weapons: Array):
	#for weapon in _weapon_resource:
		#Weapon_List[weapon.weapon_name] = weapon
	#
	#for i in _start_weapons:
		#weapon_stack.push_back(i)
	#
	#current_weapon = Weapon_List[weapon_stack[0]]
	#enter()
#
#func enter():
	#ANIMWEAPON.play("PistolArmature|Reload")
	#
#func change_weapon():
	#pass
	#
#func exit(_next_weapon: String):
	#if _next_weapon != current_weapon.weapon_name:
		#pass
		#

signal update_ammo
@onready var ANIMATIONPISTOL = %AnimationPlayer
@onready var gun_barrel = $RayCast3D
var bullet = load("res://models/weapons/pistol/bullet.tscn")
var instance

#pistol ammo
var currentammo = 12
var reserveammo = 12
var magazine = 12
var maxammo = 36

func _process(delta: float) -> void:
	if !ANIMATIONPISTOL.is_playing():
		if Input.is_action_just_pressed("attack"):
			shoot()
		if Input.is_action_just_pressed("reload"):
			reload()

func shoot():
	if currentammo != 0:
		ANIMATIONPISTOL.speed_scale = 3.0
		ANIMATIONPISTOL.play("PistolArmature|Fire")
		
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().get_parent().add_child(instance)
		currentammo -= 1
		await ANIMATIONPISTOL.animation_finished
		ANIMATIONPISTOL.speed_scale = 1.0
		emit_signal("update_ammo", currentammo, reserveammo)
	else:
		reload()

func reload():
	if currentammo == magazine:
		return
	elif reserveammo != 0:
		ANIMATIONPISTOL.play("PistolArmature|Reload")
		await ANIMATIONPISTOL.animation_finished
		ANIMATIONPISTOL.play("PistolArmature|Slide")
		await ANIMATIONPISTOL.animation_finished
		var reloadammount = min(magazine - currentammo, magazine, reserveammo)
		currentammo = currentammo + reloadammount
		reserveammo = reserveammo - reloadammount
		emit_signal("update_ammo", currentammo, reserveammo)
		
		
