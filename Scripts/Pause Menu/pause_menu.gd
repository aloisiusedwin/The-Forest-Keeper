extends Control

@onready var anim = $AnimationPlayer
@onready var timer_label = $MarginContainer/VBoxContainer/Timer
@onready var canvas = $".."
var time : float = 0.0
var timer_on : bool = true
var stop = Engine.time_scale

func _ready():
	anim.play("RESET")
	set_process_input(true) 
	timer_label.visible = false

func resume():
	canvas.visible = false
	get_tree().paused = false
	anim.play_backwards("blur")
	timer_on = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	timer_label.visible = false
	

func pause():
	canvas.visible = true
	get_tree().paused = true
	anim.play("blur")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	timer_on = true
	timer_label.visible = true

func escPress():
	if stop == 0:
		return
	elif Input.is_action_just_pressed('pause') and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed('pause') and get_tree().paused:
		resume()
	
func _process(delta):
	stop = Engine.time_scale
	escPress()

	if !get_tree().paused:
		var global = get_tree().get_root().get_node("Global")
		global.total_time += delta

	var global = get_tree().get_root().get_node("Global")
	var secs = fmod(global.total_time, 60)
	var mins = fmod(global.total_time, 60 * 60) / 60
	var hrs = fmod(fmod(global.total_time, 3600 * 60) / 3600, 24)

	var time_passed = "%02d:%02d:%02d" % [hrs, mins, secs]
	timer_label.text = time_passed

func _on_resume_pressed() -> void:
	resume()

func _on_quit_game_pressed() -> void:
	get_tree().quit()
