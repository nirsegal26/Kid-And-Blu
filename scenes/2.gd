extends Node2D

func _process(_delta: float) -> void:
	change_scenes()
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = true

func change_scenes():
	if  Global.transition_scene == true:
			get_tree().change_scene_to_file("res://scenes/world.tscn")
			Global.finish_changescene()
