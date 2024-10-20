extends RayCast3D

@onready var prompt = $Prompt
@onready var note = $"../../../CanvasLayer/Notes"
var showNote = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_exception(owner)

func Notes():
	prompt.hide()
	if showNote:
		note.hide()
		Engine.time_scale = 1
	else:
		note.show()
		Engine.time_scale = 0
	showNote = !showNote

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	prompt.text = ""
	if is_colliding():
		var collider = 	get_collider()
		if collider is Interactable:
			prompt.text = collider.prompt_message
		
			if Input.is_action_just_pressed("interact"):
				Notes()
