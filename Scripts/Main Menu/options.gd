class_name OptionsMenu
extends Control

@onready var exitButton = $MarginContainer/HBoxContainer/VBoxContainer/ExitToMenu as Button
@onready var soundSettings = $SoundOptions
@onready var soundButton = $MarginContainer/HBoxContainer/VBoxContainer/Sound
@onready var graphicsSettings = $GraphicsSettings
@onready var graphicsButton = $MarginContainer/HBoxContainer/VBoxContainer/Display
@onready var controlSettings = $ControlsSettings
@onready var controlButton = $MarginContainer/HBoxContainer/VBoxContainer/Controls
@onready var marginContainer = $MarginContainer

signal exit_options_menu

## sound
func on_sound_pressed() -> void:
	marginContainer.visible = false
	soundSettings.set_process(true)
	soundSettings.visible = true

func on_exit_sound_options() -> void:
	marginContainer.visible = true
	soundSettings.visible = false

##graphics
func on_graphics_pressed() -> void:
	marginContainer.visible = false
	graphicsSettings.set_process(true)
	graphicsSettings.visible = true

func on_exit_graphics_options() -> void:
	marginContainer.visible = true
	graphicsSettings.visible = false

##controls
func on_control_pressed() -> void:
	marginContainer.visible = false
	controlSettings.set_process(true)
	controlSettings.visible = true

func on_exit_control_options() -> void:
	marginContainer.visible = true
	controlSettings.visible = false

func _ready():
	handle_connecting_signals()
	set_process(false)

func handle_connecting_signals() -> void:
	soundButton.button_down.connect(on_sound_pressed)
	soundSettings.exit_sound_settings.connect(on_exit_sound_options)
	graphicsButton.button_down.connect(on_graphics_pressed)
	graphicsSettings.exit_graphics_settings.connect(on_exit_graphics_options)
	controlButton.button_down.connect(on_control_pressed)
	controlSettings.exit_control_settings.connect(on_exit_control_options)
	exitButton.button_down.connect(on_exit_pressed)

func on_exit_pressed() -> void:
	exit_options_menu.emit()
	set_process(false)
