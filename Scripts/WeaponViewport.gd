extends SubViewport

var screen_size : Vector2

func _ready() -> void:
	screen_size = get_window().size
	size = screen_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
