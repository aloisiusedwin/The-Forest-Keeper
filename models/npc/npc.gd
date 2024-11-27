extends Node3D

@onready var anim_tree = $AnimationPlayer

func _process(delta):
	anim_tree.play("Idle")
