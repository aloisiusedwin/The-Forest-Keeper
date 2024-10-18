extends Node3D
@onready var animation_player = %AnimationPlayer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()

func shoot():
	if animation_player.has_animation("PistolArmature|Fire"):
		animation_player.play("PistolArmature|Fire")
	else:
		print("Animation not found")

func reload():
	if animation_player.has_animation("PistolArmature|Reload"):
		animation_player.play("PistolArmature|Reload")
		await animation_player.animation_finished
	else:
		print("Animation not found")
