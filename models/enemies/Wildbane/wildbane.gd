extends CharacterBody3D

@onready var anim_tree = $AnimationTree
@onready var audio_player = $AudioStreamPlayer

var health = 2000
const speed = 4.8
const attack_range = 3.0
const damage = 40.0

var rage : bool = false
const rage_speed = 7.2
const rage_attack_range = 4.5
const rage_damage = 60.0

@onready var nav_agent = $NavigationAgent3D

var triggered = false
var state_machine
var player = null
@export var player_path : NodePath

func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")

func _process(delta):
	velocity = Vector3.ZERO
	match state_machine.get_current_node():
		"Walk":
			#Navigation Update to Player 
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"Chase":
			#Navigation Update to Player 
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * rage_speed
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10)
		"HeavyAttack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	#Action Conditions
	if triggered:
		if rage:
			anim_tree.set("parameters/conditions/heavyattack", _target_in_range())	
			anim_tree.set("parameters/conditions/chase", !_target_in_range())
		else:
			anim_tree.set("parameters/conditions/attack", _target_in_range())
			anim_tree.set("parameters/conditions/walk", !_target_in_range())
	
	anim_tree.get("parameters/playback")
	
	move_and_slide()

func _target_in_range():
	if !rage:
		if anim_tree.get("parameters/conditions/attack"):
			return global_position.distance_to(player.global_position) < 2 * attack_range
		return global_position.distance_to(player.global_position) < attack_range
	elif rage:
		if anim_tree.get("parameters/conditions/heavyattack"):
			return global_position.distance_to(player.global_position) < 2 * rage_attack_range
		return global_position.distance_to(player.global_position) < rage_attack_range

func _hit_finished():
	if !rage:
		if global_position.distance_to(player.global_position) < attack_range + 1.0:
			var dir = global_position.direction_to(player.global_position)
			player.hit(dir, damage, 10.0)
	elif rage:
		if global_position.distance_to(player.global_position) < rage_attack_range + 1.0:
			var dir = global_position.direction_to(player.global_position)
			player.hit(dir, rage_damage, 15.0)

signal defeated

func _on_area_3d_body_part_hit(dam):
	health -= dam
	print(health)
	if !triggered:
		anim_tree.set("parameters/conditions/walk", true)
	if health <= 1000:
		anim_tree.set("parameters/conditions/rage", true)
		rage = true
	if health <= 0:
		anim_tree.set("parameters/root_motion_track", Vector3.ZERO)
		anim_tree.set("parameters/conditions/dying", true)
		emit_signal("defeated")


func _player_entered(body: Node3D) -> void:
	if !triggered:
		anim_tree.set("parameters/conditions/walk", true)
		triggered = true
