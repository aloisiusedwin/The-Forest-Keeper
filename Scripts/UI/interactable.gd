extends StaticBody3D
class_name Interactable

@export var prompt_message = "Press E To Interact"
@export var isi_notes = ""
@export var can_interact : bool = true

signal interacted(body)

func interact(body):
	if can_interact:
		emit_signal("interacted", body)

func _ci_true():
	can_interact = true

func _ci_flase():
	can_interact = false
