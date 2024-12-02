extends Area3D

@onready var player = $"../Maps/NavigationRegion3D/Player"

func _on_body_entered(body: Node3D) -> void:
	player.onpanel = true

func _on_body_exited(body: Node3D) -> void:
	player.onpanel = false
