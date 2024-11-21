class_name MainMenu
extends Control


@onready var play = $"MarginContainer/HBoxContainer/VBoxContainer/Play Button" as Button
@onready var options = $"MarginContainer/HBoxContainer/VBoxContainer/Options Button" as Button
@onready var exit = $"MarginContainer/HBoxContainer/VBoxContainer/Exit Button" as Button
@onready var optionMenu = $Options as OptionsMenu
@onready var startLevel = preload("res://Scenes/forest.tscn") as PackedScene
@onready var marginContainer = $MarginContainer as MarginContainer

func _ready():
	handle_connecting_signals()
	
func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(startLevel)
	
func on_options_pressed() -> void:
	marginContainer.visible = false
	optionMenu.set_process(true)
	optionMenu.visible = true
	
func on_exit_pressed() -> void:
	get_tree().quit()

func on_exit_options_menu() -> void:
	marginContainer.visible = true
	optionMenu.visible = false

func handle_connecting_signals() -> void:
	play.button_down.connect(on_start_pressed)
	options.button_down.connect(on_options_pressed)
	exit.button_down.connect(on_exit_pressed)
	optionMenu.exit_options_menu.connect(on_exit_options_menu)
