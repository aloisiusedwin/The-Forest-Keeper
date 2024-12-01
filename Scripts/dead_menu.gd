extends Control

@onready var startLevel = preload("res://Scenes/Level/Forest/forest.tscn") as PackedScene
@onready var play = $"MarginContainer/HBoxContainer/VBoxContainer/Play Again"
@onready var exit = $"MarginContainer/HBoxContainer/VBoxContainer/Exit Button"


func _ready() -> void:
	handle_connecting_signals()

func _process(delta: float) -> void:
	pass

func on_exit_pressed() -> void:
	get_tree().quit()

func on_play_pressed() -> void:
	get_tree().change_scene_to_packed(startLevel)

func handle_connecting_signals() -> void:
	play.button_down.connect(on_play_pressed)
	exit.button_down.connect(on_exit_pressed)
