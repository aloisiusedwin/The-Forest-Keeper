class_name SoundOptions
extends Control

@onready var backButton = $MarginContainer/HBoxContainer/VBoxContainer/Back as Button

signal exit_sound_settings

func _ready():
	handle_connecting_signals()
	set_process(false)

func on_exit_pressed() -> void:
	exit_sound_settings.emit()
	set_process(false)

func handle_connecting_signals() -> void:
	backButton.button_down.connect(on_exit_pressed)
	
