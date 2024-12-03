extends Area3D

@onready var flanker1 = $"../MovingStatue"
@onready var flankers = $"../MovingStatue2"

func _on_body_entered(body: Node3D) -> void:
	flanker1.stopping = true
	flanker1. triggered = false
	flankers.triggered = true
