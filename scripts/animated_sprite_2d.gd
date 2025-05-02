extends AnimatedSprite2D

@onready var margin = Vector2(300, -80) # מרחק מהפינה

func _ready():
	update_position()
	get_viewport().size_changed.connect(update_position) # ← שינוי חשוב כאן!

func update_position():
	var screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x - margin.x, margin.y)
