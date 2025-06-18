extends Node2D
var scene_to_load := "res://scenes/9.tscn"

func _ready() -> void:
	load_scene_async()

func load_scene_async() -> void:
	

	# מחכה שהסצנה תיטען ברקע
	var result = await ResourceLoader.load_threaded_request(scene_to_load)

	if result is PackedScene:
		get_tree().change_scene_to_packed(result)


func _process(_delta: float) -> void:
	change_scenes()
	

func change_scenes():
	if  Global.transition_scene == true:
			get_tree().change_scene_to_file("res://scenes/9.tscn")
			Global.finish_changescene()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = true
