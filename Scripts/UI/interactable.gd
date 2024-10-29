extends CollisionObject3D
class_name Interactable

@export var prompt_message = "Press E To Interact"

func interact(body):
	print(body.name, " interact with ", name)
