extends Node

@export var spawn_interval := 5.0
@export var initial_delay := 7.0  

var crow_scene: PackedScene = load("res://scenes/energy_ball.tscn")

var corners := [
	Vector2(0, 0),
	Vector2(1152, 0),
	Vector2(0, 648),
	Vector2(1152, 648)
]

func _ready():
	randomize()
	print("READY")

	await get_tree().create_timer(initial_delay).timeout

	print("⏳ Delay over, starting spawner")
	spawn_crow()
	start_spawning()

func start_spawning():
	var timer := Timer.new()
	timer.wait_time = spawn_interval
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(spawn_crow)
	add_child(timer)
	print("Spawner timer started")

func spawn_crow():
	print("spawn_crow called")

	if not is_instance_valid(crow_scene):
		print("Crow scene not set.")
		return

	var crow = crow_scene.instantiate()
	var random_pos = corners[randi() % corners.size()]
	crow.global_position = random_pos
	add_child(crow)
	print("Spawning crow at:", random_pos)
