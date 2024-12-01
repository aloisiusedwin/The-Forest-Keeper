extends RayCast3D

@onready var player = $"../../.."

@onready var object_found = false
@onready var prompt = $Prompt
@onready var note = $"../../../PlayerHUD/CanvasLayer/Note"
@onready var label2d = $"../../../PlayerHUD/CanvasLayer/Note/Label"

@onready var map2_basement = $"../../../PlayerHUD/CanvasLayer/map2_basement"
@onready var map2_lt1 = $"../../../PlayerHUD/CanvasLayer/map2_lt1"
@onready var map2_lt2 = $"../../../PlayerHUD/CanvasLayer/map2_lt2"
@onready var map3_pabrik = $"../../../PlayerHUD/CanvasLayer/map3_pabrik"
@onready var sidequest = $"../../../PlayerHUD/CanvasLayer/map3_sidequest"

var showNote = false
var showMaps = false

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

func Maps(map_node):
	prompt.hide()
	if showMaps:
		map_node.hide()
		Engine.time_scale = 1
	else:
		map_node.show()
		Engine.time_scale = 0
	showMaps = !showMaps
	if !showMaps:
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
					Dialogic.start("meno1")
				elif collider.name == "lee":
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
				elif collider.name == "map_basement":
					collider.interact(self)
					Maps(map2_basement)
				elif collider.name == "map2_lt1":
					collider.interact(self)
					Maps(map2_lt1)
				elif collider.name == "map2_lt2":
					collider.interact(self)
					Maps(map2_lt2)
				elif collider.name == "sidequest":
					collider.interact(self)
					Maps(sidequest)
				elif collider.name == "map3_pabrik":
					collider.interact(self)
					Maps(map3_pabrik)
				else:
					collider.interact(self)  # Memanggil interact() dari Interactable
					Notes(collider.isi_notes)  # Mengirim isi_notes ke fungsi Notes
				
func DialogicSignal(argument:String):
	if argument == "started":
		player.stop_input = true
		prompt.visible = !prompt.visible
	elif argument == "ended":
		player.stop_input = false
		prompt.visible = !prompt.visible
