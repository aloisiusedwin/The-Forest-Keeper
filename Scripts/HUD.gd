extends CanvasLayer

@onready var CurrentAmmo = $VBoxContainer/HBoxContainer/MarginContainer/CurrentAmmo


func _on_pistol_update_ammo(current,reserve) -> void:
	CurrentAmmo.set_text(str(current) + " | " + str(reserve))