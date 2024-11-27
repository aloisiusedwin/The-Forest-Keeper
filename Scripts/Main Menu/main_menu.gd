class_name MainMenu
extends Control


@onready var play = $"Background/MarginContainer/HBoxContainer/VBoxContainer/Play Button"
@onready var options = $"Background/MarginContainer/HBoxContainer/VBoxContainer/Options Button"
@onready var exit = $"Background/MarginContainer/HBoxContainer/VBoxContainer/Exit Button"
@onready var optionMenu = $Options as OptionsMenu
@onready var startLevel = preload("res://Scenes/Level/Forest/forest.tscn") as PackedScene
@onready var marginContainer = $Background/MarginContainer
@onready var subviewport = $Background/SubViewportContainer

func _ready():
	handle_connecting_signals()
	
func on_start_pressed() -> void:
	print("pressed")
	get_tree().change_scene_to_packed(startLevel)
	
func on_options_pressed() -> void:
	marginContainer.visible = false
	subviewport.visible = false
	optionMenu.set_process(true)
	optionMenu.visible = true
	
func on_exit_pressed() -> void:
	get_tree().quit()

func on_exit_options_menu() -> void:
	marginContainer.visible = true
	subviewport.visible = true
	optionMenu.visible = false

func handle_connecting_signals() -> void:
	play.button_down.connect(on_start_pressed)
	options.button_down.connect(on_options_pressed)
	exit.button_down.connect(on_exit_pressed)
	optionMenu.exit_options_menu.connect(on_exit_options_menu)
