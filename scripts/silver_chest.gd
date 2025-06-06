extends CharacterBody2D

var in_shopping_area := false
var open = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		in_shopping_area = true
		await get_tree().create_timer(0.7).timeout
		if in_shopping_area: # Check if Player Still There
			$AnimationPlayer2.play("new_animation")



func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_shopping_area = false
		$AnimationPlayer2.play("fade_away")

func _process(_delta):
	if in_shopping_area and Input.is_action_just_pressed("interact") and open == false:
		$open_chest.play()
		$AnimatedSprite2D.play("default")
		await $AnimatedSprite2D.animation_finished
		$AnimationPlayer.play("heart")
		Global.player_health += 30
		open = true
		$detection_area.queue_free()
