extends Node3D

@onready var spawns = $Maps/SpawnPoint
@onready var nav_region = $Maps/NavigationRegion3D
var tormenter = load("res://models/enemies/tormenter/tormenter.tscn")
var instance 

func _ready():
	randomize()

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)

func _on_enemy_spawn_timer_timeout() -> void:
	var spawn_point = _get_random_child(spawns).global_position
	instance = tormenter.instantiate()
	instance.position = spawn_point
	nav_region.add_child(instance)
	
	
