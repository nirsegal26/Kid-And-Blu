extends Node

var crow_scene: PackedScene = preload("res://scenes/energy_ball.tscn")
@export var spawn_interval := 5.0  # כל כמה שניות נוצרת ציפור

var corners := [
	Vector2(0, 0),             # שמאל למעלה
	Vector2(1152, 0),          # ימין למעלה
	Vector2(0, 648),          # שמאל למטה
	Vector2(1152, 648)        # ימין למטה
]

func _ready():
	spawn_crow()  # הראשון מיידית
	start_spawning()

func start_spawning():
	var timer := Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(spawn_crow)
	add_child(timer)

func spawn_crow():
	if not is_instance_valid(crow_scene):
		print("Crow scene not set.")
		return

	var crow = crow_scene.instantiate()
	var random_pos = corners[randi() % corners.size()]
	crow.global_position = random_pos
	get_tree().current_scene.call_deferred("add_child", crow)
