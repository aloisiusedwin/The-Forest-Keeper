extends CharacterBody3D

@onready var anim_tree = $AnimationTree

const speed = 4
const attack_range = 2.0
@onready var nav_agent = $NavigationAgent3D

var state_machine
var player = null
@export var player_path := "/root/World/Maps/NavigationRegion3D/CharacterBody3D"


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
	
	#Action Conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/walk", !_target_in_range())
	
	anim_tree.get("parameters/playback")
	
	move_and_slide()


func _target_in_range():
	if anim_tree.get("parameters/conditions/attack"):
		return global_position.distance_to(player.global_position) < 2 * attack_range
	return global_position.distance_to(player.global_position) < attack_range

func _hit_finished():
	if global_position.distance_to(player.global_position) < attack_range + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)
