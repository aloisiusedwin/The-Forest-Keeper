extends CenterContainer

@export var DOT_RADIUS : float = 2.0
@export var DOT_COLOR : Color = Color.WHITE


func _ready():
	queue_redraw()

func _process(delta):
	pass

func _draw():
	var center = size / 2
	draw_circle(center, DOT_RADIUS, DOT_COLOR)
