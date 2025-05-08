extends Node2D

func _process(_delta: float) -> void:
	change_scene()

func _ready() -> void:
	Global.update_current_scene("home_inside")

	if Global.game_first_loadin:
		$AnimationPlayer.play("blur")
		get_tree().paused = false
		$Player.position = Vector2(Global.player_start_posx, Global.player_start_posy)
	else:
		$ColorRect.hide()
		$AnimationPlayer.play("show")
		$Player.direct = "up"
		$Player.position = Vector2(Global.player_exit_cliffside_posx, Global.player_exit_cliffside_posy)


# Open The House Door
func _on_opendoorarea_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		$AnimatedSprite2D.play("open")

# Close The House Door
func _on_opendoorarea_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		$AnimatedSprite2D.play("close")


func _on_cliffside_transition_point_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = true

func _on_cliffside_transition_point_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = false
		
func change_scene():
	if Global.transition_scene == true:
		if Global.current_scene == "home_inside":
			get_tree().change_scene_to_file("res://scenes/home.tscn")
			Global.game_first_loadin = false
			Global.finish_changescene()
