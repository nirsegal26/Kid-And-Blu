extends CharacterBody2D

var in_shopping_area := false

func _process(delta):
	if in_shopping_area and Input.is_action_just_pressed("interact"):
		print("space")
		Global.previous_scene = get_tree().current_scene.scene_file_path  # Saving
		Global.update_current_scene(Global.previous_scene)  # Saving for Global
		get_tree().change_scene_to_file("res://scenes/inside_shop.tscn")


func _on_shopping_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		in_shopping_area = true
		await get_tree().create_timer(1.5).timeout
		if in_shopping_area: # Check if Player Still There
			$AnimationPlayer.play("new_animation")

func _on_shopping_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_shopping_area = false
		$AnimationPlayer.play("fade_away")
