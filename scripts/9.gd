extends Node2D

var can_anim = true
var skeletons := []
var enemy_move := true
var princes := []
var enemy_move2 := true
var scene_to_load := "res://scenes/10.tscn"
var ghost_shader := preload("res://scenes/6.gdshader")
func _ready() -> void:
	skeletons = [
		$Minotaur, $Minotaur2, $Minotaur3, $Minotaur4, $Minotaur5,
		$Minotaur6, $Minotaur7, $Minotaur8, $Minotaur9, $Minotaur10,
		$Minotaur11, $Minotaur12, $Minotaur13, $Minotaur14, $Minotaur15,
		$Minotaur16, $Minotaur17, $Skeleton, $Skeleton2, $Skeleton3,
		$Skeleton4, $Skeleton5, $Skeleton6
	]

	princes = [$Prince, $Prince2]

	freeze_enemies()
	freeze_princes()
	load_scene_async()

func load_scene_async() -> void:
	var result = await ResourceLoader.load_threaded_request(scene_to_load)
	if result is PackedScene:
		get_tree().change_scene_to_packed(result)

func freeze_princes():
	for prince in princes:
		if prince.has_node("AnimatedSprite2D"):
			var sprite: AnimatedSprite2D = prince.get_node("AnimatedSprite2D")
			prince.set_physics_process(false)
			prince.set_process(false)
			for child in prince.get_children():
				if child is Area2D:
					child.set_monitoring(false)
				elif child is Timer:
					child.stop()
			if "velocity" in prince:
				prince.velocity = Vector2.ZERO
			sprite.play("Idle")

func freeze_enemies():
	for skeleton in skeletons:
		if skeleton.has_node("AnimatedSprite2D"):
			var sprite: AnimatedSprite2D = skeleton.get_node("AnimatedSprite2D")
			skeleton.set_physics_process(false)
			skeleton.set_process(false)
			for child in skeleton.get_children():
				if child is Area2D:
					child.set_monitoring(false)
				elif child is Timer:
					child.stop()
			if "velocity" in skeleton:
				skeleton.velocity = Vector2.ZERO
			sprite.play("Idle")

func unfreeze_enemies():
	for skeleton in skeletons:
		if skeleton.has_node("AnimatedSprite2D"):
			var sprite: AnimatedSprite2D = skeleton.get_node("AnimatedSprite2D")
			skeleton.set_process(true)
			skeleton.set_physics_process(true)
			for child in skeleton.get_children():
				if child is Area2D:
					child.set_monitoring(true)
				elif child is Timer:
					child.start()
			sprite.play("Idle")

func unfreeze_princes():
	for prince in princes:
		if prince.has_node("AnimatedSprite2D"):
			var sprite: AnimatedSprite2D = prince.get_node("AnimatedSprite2D")
			prince.set_process(true)
			prince.set_physics_process(true)
			for child in prince.get_children():
				if child is Area2D:
					child.set_monitoring(true)
				elif child is Timer:
					child.start()
			sprite.play("Idle")

func _on_det_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and enemy_move:
		$horn.play()
		await get_tree().create_timer(0.5).timeout
		if $AudioStreamPlayer.is_inside_tree():
			$AudioStreamPlayer.play()
		unfreeze_enemies()
		enemy_move = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and enemy_move2:
		unfreeze_princes()
		enemy_move2 = false

func _on_open_door_body_entered(body: Node2D) -> void:
	if body.name == "Player" and get_tree().current_scene.name == "9":
		if $AnimatedSprite2D.is_inside_tree():
			$AnimatedSprite2D.play("open")
		if $open.is_inside_tree():
			$open.play()

func _on_open_door_body_exited(body: Node2D) -> void:
	if body.name == "Player" and get_tree().current_scene.name == "9":
		if $AnimatedSprite2D.is_inside_tree():
			$AnimatedSprite2D.play("close")
		if $close.is_inside_tree():
			$close.call_deferred("play")

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.has_method("player") and can_anim:
		can_anim = false
		$AnimationPlayer.play("new_animation")
		await get_tree().create_timer(2).timeout
		$AnimationPlayer.play("fade_away")

func _process(_delta: float) -> void:
	change_scenes()

func change_scenes():
	if Global.transition_scene:
		Global.transition_scene = false
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file("res://scenes/10.tscn")

func _on_change_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = true
