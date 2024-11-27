extends Node3D

@export_node_path("Player") var controller_path := NodePath("../Maps/NavigationRegion3D/Player")
@onready var controller : Player = get_node(controller_path)

func _on_hand_interacted(_body) -> void:
	queue_free()
