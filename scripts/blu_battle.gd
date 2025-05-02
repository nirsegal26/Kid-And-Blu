extends Node2D

var minotaurs := []
var camera_move = true
var enemy_move = true
@onready var camera_target_position := Vector2(834, 341)  # Battle Position
@onready var wait_duration := 3.0

func _ready() -> void:
	$Blu.set_physics_process(false)
	$Blu.velocity = Vector2.ZERO
	$Blu.get_node("AnimatedSprite2D").play("Worry") # Play BLU's Worry Anim

	# Enemies List
	minotaurs = [
		$Minotaur,
		$Minotaur2,
		$Minotaur3,
		$Minotaur4,
		$Minotaur5
	]

	# First Enemies and First Animations
	for minotaur in minotaurs:
		if minotaur.has_node("AnimatedSprite2D"):
			var sprite: AnimatedSprite2D = minotaur.get_node("AnimatedSprite2D")
			minotaur.set_physics_process(false)
			minotaur.velocity = Vector2.ZERO
			await get_tree().create_timer(0.2).timeout
			sprite.play("Idle")


# Once The Player in Zone, Release the Enemies
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and enemy_move == true:
		enemy_move = false  # Work Only Once
		for minotaur in minotaurs:
			minotaur.set_physics_process(true)
			var sprite = minotaur.get_node("AnimatedSprite2D")
			if sprite and sprite.animation != "Walk":
				sprite.play("Walk")



# Once the Player Enter Watch Zone, The Camera Moves To Battle, Stops and Returns
func _on_fight_watch_area_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	if camera_move == true:
		$Player.set_physics_process(false)
		$Player.get_node("AnimatedSprite2D").play("FrontIdle")
		var camera: Camera2D = body.get_node_or_null("Camera2D")

		var original_position: Vector2 = camera.global_position
		var target_position: Vector2 = Vector2(834, 341)  

	# Smooth Movement to Battle
		create_tween().tween_property(camera, "global_position", target_position, 2.0)
		camera_move = false
		await get_tree().create_timer(3.0).timeout
		
	# Back to Player
		create_tween().tween_property(camera, "global_position", original_position, 2.0)
		$Player.set_physics_process(true)
