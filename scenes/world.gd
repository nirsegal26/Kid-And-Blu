extends Node2D
func _ready() -> void:
	$Blu.get_node("AnimatedSprite2D").play("Idle")

func _process(_delta: float) -> void:
	change_scenes()

func change_scenes():
	if  Global.transition_scene == true:
			get_tree().change_scene_to_file("res://scenes/3.tscn")
			Global.finish_changescene()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = true
