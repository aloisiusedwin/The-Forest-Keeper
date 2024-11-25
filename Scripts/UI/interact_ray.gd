extends RayCast3D

@onready var prompt = $Prompt
@onready var note = $"../../../PlayerHUD/CanvasLayer/Note"
@onready var label2d = $"../../../PlayerHUD/CanvasLayer/Note/Label"
var showNote = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_exception(owner)

func Notes(isi_notes: String):
	prompt.hide()
	if showNote:
		note.hide()
		Engine.time_scale = 1
	else:
		label2d.text = isi_notes  # Set text di Label2D dengan isi_notes dari Interactable
		note.show()
		Engine.time_scale = 0
	showNote = !showNote
	if !showNote:
		prompt.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	prompt.text = ""
	if is_colliding():
		var collider = get_collider()
		if collider is Interactable:
			prompt.text = collider.prompt_message
			if Input.is_action_just_pressed("interact"):
				if collider.name == "flashy" || collider.name == "lockeddoor":
					collider.interact(owner) 
				else:
					collider.interact(self)  # Memanggil interact() dari Interactable
					Notes(collider.isi_notes)  # Mengirim isi_notes ke fungsi Notes
				
