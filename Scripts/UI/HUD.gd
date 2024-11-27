extends CanvasLayer

@onready var CurrentAmmo = $VBoxContainer/HBoxContainer/MarginContainer/CurrentAmmo

func _process(delta: float) -> void:
	var weapon_manager = $"../../WeaponManager"
	if weapon_manager.current_weapon:
		var weapon = weapon_manager.current_weapon
		CurrentAmmo.set_text(str(weapon.current_ammo) + " | " + str(weapon.reserve_ammo))
		
