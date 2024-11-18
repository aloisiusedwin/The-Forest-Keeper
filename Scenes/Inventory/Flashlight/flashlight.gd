extends Node3D

@export_node_path("Player") var controller_path := NodePath("../Maps/NavigationRegion3D/CharacterBody3D")

@onready var controller : Player = get_node(controller_path)
@onready var animator : AnimationPlayer = get_node(NodePath("AnimationPlayer"))
@onready var flashlight_sfx : AudioStreamPlayer3D = get_node(NodePath("FlashlightSfx"))

func _on_static_body_3d_interacted(_body) -> void:
	animator.play("pickup")
	controller.can_use_torch = true

func _audio_play() -> void:
	flashlight_sfx.play()
	flashlight_sfx.pitch_scale = randf_range(0.8, 1.2)
