extends Node

var debug
var player

var total_time: float = 0.0

func _ready():
	## Membuat node tetap ada meski scene berubah
	get_tree().get_root().add_child(self)
	set_owner(get_tree().get_root())
