extends AnimatedSprite2D

@onready var margin = Vector2(170, 540) 

func _ready():
	update_position()
	get_viewport().size_changed.connect(update_position) 

func update_position():
	var screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x - margin.x, margin.y)
