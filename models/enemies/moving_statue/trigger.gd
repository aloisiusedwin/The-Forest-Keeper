extends Area3D

@onready var flankers = $"../MovingStatue"

func _on_body_entered(body: Node3D) -> void:
	print("1")
	print(body.name)
	flankers.triggered = true