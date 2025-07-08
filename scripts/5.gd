extends Node2D

var scene_to_load := "res://scenes/11.tscn"
var ghost_shader := preload("res://scenes/6.gdshader")
var loaded_scene: PackedScene = null

func _ready() -> void:
	$AnimationPlayer.play("start")
	load_scene_async()

func load_scene_async() -> void:
	var ok := ResourceLoader.load_threaded_request(scene_to_load)
	if ok != OK:
		push_error("Failed to start async load for: " + scene_to_load)
		return

	await wait_for_load(scene_to_load)

func wait_for_load(path: String) -> void:
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame

	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var result = ResourceLoader.load_threaded_get(path)
		if result is PackedScene:
			loaded_scene = result
			print("Scene loaded and ready.")
		else:
			push_error("Loaded resource is not a PackedScene!")
	else:
		push_error("Scene loading failed with status: " + str(status))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		$AnimationPlayer.play("night")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		$AnimationPlayer.play("day")

func _on_advance_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player") and loaded_scene:
		Global.transition_scene = true

func _process(_delta: float) -> void:
	if Global.transition_scene and loaded_scene:
		Global.transition_scene = false
		call_deferred("_switch_scene")

func _switch_scene():
	var new_scene = loaded_scene.instantiate()

	if get_tree().current_scene:
		get_tree().current_scene.call_deferred("free")

	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

	await get_tree().process_frame
	Global.finish_changescene()
