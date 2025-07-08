extends Node2D

# הנתיב לסצנה שנטען
@export var scene_to_load: String = "res://scenes/10.tscn"
var varing = false
var loaded_scene: PackedScene = null

func _ready():
	# להתחיל טעינה אסינכרונית
	
	anim()

func anim():
	$AnimationPlayer.play("new_animation")
	await $AnimationPlayer.animation_finished
	varing = true
	load_scene_async()
func load_scene_async() -> void:
	print("Loading scene in background: ", scene_to_load)
	var ok := ResourceLoader.load_threaded_request(scene_to_load)
	if ok != OK:
		push_error("Failed to start async load for: " + scene_to_load)
		return
	await wait_for_load(scene_to_load)

func wait_for_load(path: String) -> void:
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame

	var result = ResourceLoader.load_threaded_get(path)
	if result is PackedScene:
		loaded_scene = result
		call_deferred("_switch_scene")

func _switch_scene():
	if varing == true:
		$AnimationPlayer.play("fade")
		await get_tree().create_timer(1).timeout 
		var new_scene = loaded_scene.instantiate()

		if get_tree().current_scene:
			get_tree().current_scene.call_deferred("free")

		get_tree().root.add_child(new_scene)
		get_tree().current_scene = new_scene

		await get_tree().process_frame
		print("Scene switched successfully.")
