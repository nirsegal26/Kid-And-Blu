extends Node2D

var can_anim = true
var scene_to_load := "res://scenes/13.tscn"
var loaded_scene: PackedScene = null
var ghost_shader := preload("res://scenes/7.gdshader")  

func _ready() -> void:
	load_scene_async()

func load_scene_async() -> void:
	print("Start async load of: ", scene_to_load)
	var ok := ResourceLoader.load_threaded_request(scene_to_load)
	if ok != OK:
		push_error("Failed to load scene: " + scene_to_load)
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
			push_error("Scene loaded but not PackedScene.")
	else:
		push_error("Scene loading failed. Status: " + str(status))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player") and can_anim:
		can_anim = false
		$AnimationPlayer.play("new_animation")
		await get_tree().create_timer(2).timeout
		$AnimationPlayer.play("fade_away")

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = true

func _process(_delta: float) -> void:
	if Global.transition_scene and loaded_scene:
		Global.transition_scene = false
		call_deferred("_switch_scene")

func _switch_scene():
	var new_scene := loaded_scene.instantiate()

	if get_tree().current_scene:
		get_tree().current_scene.call_deferred("free")

	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

	await get_tree().process_frame
	Global.finish_changescene()
