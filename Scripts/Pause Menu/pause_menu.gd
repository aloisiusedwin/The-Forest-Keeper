extends Control

@onready var anim = $AnimationPlayer
@onready var timer_label = $MarginContainer/VBoxContainer/Timer
@onready var canvas_pause = $".."
var time : float = 0.0
var timer_on : bool = true

func _ready():
	anim.play("RESET")
	set_process_input(true) 
	timer_label.visible = false

func resume():
	canvas_pause.visible = !canvas_pause.visible
	get_tree().paused = false
	anim.play_backwards("blur")
	timer_on = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	timer_label.visible = false

func pause():
	canvas_pause.visible = !canvas_pause.visible
	get_tree().paused = true
	anim.play("blur")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	timer_on = true
	timer_label.visible = true
	
func _process(delta):
	
	if !get_tree().paused:
		time += delta
	
	var secs = fmod(time, 60)
	var mins = fmod(time, 60 * 60) / 60
	var hrs = fmod(fmod(time, 3600 * 60) / 3600, 24)
	
	var time_passed = "%02d:%02d:%02d" % [hrs,mins,secs]
	timer_label.text = time_passed

func _on_resume_pressed() -> void:
	resume()

func _on_quit_game_pressed() -> void:
	get_tree().quit()
