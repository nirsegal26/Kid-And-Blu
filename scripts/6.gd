extends Node2D
var can_anim = true
var scene_to_load := "res://scenes/7.tscn"

func _ready() -> void:
	load_scene_async()

func load_scene_async() -> void:
	

	# מחכה שהסצנה תיטען ברקע
	var result = await ResourceLoader.load_threaded_request(scene_to_load)

	if result is PackedScene:
		get_tree().change_scene_to_packed(result)

		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player") and can_anim == true:
		can_anim = false
		$AnimationPlayer.play("new_animation")
		await get_tree().create_timer(2).timeout
		$AnimationPlayer.play("fade_away")
		



func _process(_delta: float) -> void:
	change_scenes()
	
func _on_area_2d_2_body_entered(body: Node2D) -> void:
	print("1")
	if body.has_method("player"):
		print("2")
		Global.transition_scene = true

func change_scenes():
	if  Global.transition_scene == true:
			get_tree().change_scene_to_file("res://scenes/7.tscn")
			Global.finish_changescene()
