extends Area3D

@onready var flankers = $"../MovingStatue2"

func _on_body_entered(body: Node3D) -> void:
	flankers.triggered = true
