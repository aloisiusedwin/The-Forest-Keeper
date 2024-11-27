extends RayCast3D

@onready var object_found = false
@onready var prompt = $Prompt
@onready var note = $"../../../PlayerHUD/CanvasLayer/Note"
@onready var label2d = $"../../../PlayerHUD/CanvasLayer/Note/Label"
var showNote = false

signal found

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(DialogicSignal)
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
				if collider.name == "meno":
					prompt.visible = !prompt.visible
					Dialogic.start("meno1")
				elif collider.name == "lee":
					prompt.visible = !prompt.visible
					if object_found:
						collider.queue_free()
						Dialogic.start("meno2")
						emit_signal("found")
					else:
						Dialogic.start("quest_start")
				elif collider.name == "flashy" || collider.name == "lockeddoor" || collider.name == "hand":
					if collider.name == "hand":
						object_found = true
					collider.interact(owner) 
				else:
					collider.interact(self)  # Memanggil interact() dari Interactable
					Notes(collider.isi_notes)  # Mengirim isi_notes ke fungsi Notes
				
func DialogicSignal(argument:String):
	if argument == "ended":
		prompt.visible = !prompt.visible
