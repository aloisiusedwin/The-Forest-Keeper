extends Node3D

@onready var player = $Maps/NavigationRegion3D/Player
@onready var spawns = $Maps/SpawnPoint
@onready var nav_region = $Maps/NavigationRegion3D
var tormenter = load("res://models/enemies/tormenter/tormenter.tscn")
var instance
var kill_count = 0
var tormenter_count = 0

func _ready():
	randomize()

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)

func _on_enemy_spawn_timer_timeout() -> void:
	if tormenter_count <= 10:
		tormenter_count += 1
		
		var spawn_point = _get_random_child(spawns).global_position
		instance = tormenter.instantiate()
		instance.position = spawn_point
		nav_region.add_child(instance)
		instance.connect("modar", Callable(self, "_tormenter_modar"))

func _tormenter_modar():
	tormenter_count -= 1
	kill_count += 1
	
	if kill_count >= 25:
		player.forest_alternate()
