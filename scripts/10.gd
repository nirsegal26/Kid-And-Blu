extends Node2D
var enemies := []
var camera_move := true
@onready var camera_target_position := Vector2(546, 215)
@onready var wait_duration := 3.0
@onready var player := get_tree().current_scene.get_node_or_null("Player")
var enemy_move := true
var scene_to_load := "res://scenes/win.tscn"
func _ready() -> void:
	enemies = [
		$Minotaur, $Minotaur2, $Minotaur3, $Minotaur4, $Minotaur5,
		$Minotaur6, $Minotaur7, $Minotaur8, $Minotaur9, $Minotaur10,
		$Minotaur11, $Minotaur12, $Minotaur13, $Minotaur14, $Minotaur15,
		$Minotaur16, $Minotaur17, $Minotaur18, $Minotaur19
	]
	$King.connect("died", Callable(self, "_on_king_died"))
	$AnimationPlayer2.play("rr")
	$Player.direct = "up"
	for enemy in enemies:
		enemy.set_physics_process(false)
		enemy.set_process(false)
		enemy.get_node("AnimatedSprite2D").play("Idle")
	$King.set_physics_process(false)
	$King.set_process(false)
	$King.get_node("AnimatedSprite2D").play("Idle")
	load_scene_async()
	
	
func load_scene_async() -> void:
	

	# מחכה שהסצנה תיטען ברקע
	var result = await ResourceLoader.load_threaded_request(scene_to_load)

	if result is PackedScene:
		get_tree().change_scene_to_packed(result)

func _on_fight_watch_area_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	if camera_move:
		camera_move = false
		player.set_physics_process(false)
		player.get_node("AnimatedSprite2D").play("BackIdle")

		var camera: Camera2D = body.get_node_or_null("Camera2D")
		var original_position: Vector2 = camera.global_position
		var target_position: Vector2 = camera_target_position

		create_tween().tween_property(camera, "global_position", target_position, 2.0)
		await get_tree().create_timer(2.0).timeout
		$beast.play()
		$King.get_node("AnimatedSprite2D").play("Down_attack")
		await get_tree().create_timer(1.0).timeout
		create_tween().tween_property(camera, "global_position", original_position, 2.0)
		await get_tree().create_timer(2.0).timeout
		player.set_physics_process(true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and enemy_move:
		enemy_move = false
		$King.set_physics_process(true)
		for enemy in enemies:
			enemy.set_physics_process(true)

func _on_king_died() -> void:
	$beast.play()
	$AnimationPlayer.play("new_animation")
	for enemy in enemies:
		if enemy and enemy.is_inside_tree() and not enemy.is_dead:
			enemy.die()
	$CrowSpawner.set_process(false)
	$CrowSpawner.set_physics_process(false)
	$CrowSpawner.queue_free()
	$AudioStreamPlayer.stop()
	await get_tree().create_timer(2.5).timeout 
	$AnimationPlayer2.play("new_animation")
	await $AnimationPlayer2.animation_finished
	get_tree().change_scene_to_file("res://scenes/win.tscn")
