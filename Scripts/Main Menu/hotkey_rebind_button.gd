class_name HotkeyRebindButton
extends Control


@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button

@export var action_name : String = ""

func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()
	
func set_action_name() -> void:
	label.text = "Unassigned"
	
	match action_name:
		"up":
			label.text = "Move Forward"
		"down":
			label.text = "Move Backward"
		"right":
			label.text = "Move Right"
		"left":
			label.text = "Move Left"
		"sprint":
			label.text = "Run"
		"jump":
			label.text = "Jump"
		"crouch":
			label.text = "Crouch"
		"attack":
			label.text = "Attack"
		"reload":
			label.text = "Reload"
		"weapon_up":
			label.text = "Weapon Up"
		"weapon_down":
			label.text = "Weapon Down"
		"interact":
			label.text = "Interact"
		"toggle_torch":
			label.text = "Toggle Torch"

func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	
	if action_events.size() > 0:
		var action_event = action_events[0]
		if action_event is InputEventKey:
			var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
			button.text = "%s" % action_keycode
		elif action_event is InputEventMouseButton:
			button.text = "Mouse Button %d" % action_event.button_index
		else:
			button.text = "Unsupported Input"
	else:
		button.text = "No Input Event"

func _on_button_toggled(button_pressed) -> void:
	if button_pressed:
		button.text = "Press any key.."
		set_process_unhandled_key_input(button_pressed)
		
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
				
	else:
		
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
				
		set_text_for_key()


func _unhandled_key_input(event):
	rebind_action_key(event)
	button.button_pressed = false
	
func rebind_action_key(event):
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()
