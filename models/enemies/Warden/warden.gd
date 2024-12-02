extends CharacterBody3D

@onready var anim_tree = $AnimationTree
var health = 300
const speed = 5
const attack_range = 1.5
const damage = 30.0
@onready var nav_agent = $NavigationAgent3D

var triggered = false
var state_machine
var player = null
@export var player_path := "/root/Pabrik/Maps/NavigationRegion3D/Player"

func _ready():
	
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
func _process(delta):
	velocity = Vector3.ZERO
	match state_machine.get_current_node():
		"Chase":
			#Navigation Update to Player 
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	#Action Conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/chase", !_target_in_range())
	
	anim_tree.get("parameters/playback")
	
	move_and_slide()

func _target_in_range():
	if anim_tree.get("parameters/conditions/attack"):
		return global_position.distance_to(player.global_position) < 2 * attack_range
	return global_position.distance_to(player.global_position) < attack_range

func _hit_finished():
	if global_position.distance_to(player.global_position) < attack_range + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir, damage, 8.0)

func _on_area_3d_body_part_hit(dam):
	health -= dam
	if !triggered:
		anim_tree.set("parameters/conditions/idle", true)
	if health <= 0:
		anim_tree.set("parameters/root_motion_track", Vector3.ZERO)
		anim_tree.set("parameters/conditions/dying", true)
		await get_tree().create_timer(4.0).timeout
		queue_free()	

func _player_entered(body: Node3D) -> void:
	if !triggered:
		anim_tree.set("parameters/conditions/idle", true)
