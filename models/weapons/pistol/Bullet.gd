extends Node3D

const speed = 300
var velocity = Vector3.ZERO

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	position += velocity * delta
	if ray.is_colliding():
		mesh.visible = false
		particles.emitting = true
		ray.enabled = false
		if ray.get_collider().is_in_group("enemy"):
			ray.get_collider().hit()
		await get_tree().create_timer(1.0).timeout
		queue_free()
		

func set_velocity(target):
	look_at(target)
	velocity = position.direction_to(target) * speed

func _on_timer_timeout() -> void:
	queue_free()
