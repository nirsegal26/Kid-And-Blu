extends CharacterBody2D
var is_attacking := false
var SPEED = 45.0
var player_chase = false
var player : Node2D = null
var health = 100
var player_inattack_zone = false
var can_take_damage = true
var is_dead = false
var patrol_direction := Vector2(1, 0)
var patrol_change_timer := 0.0
signal died
@onready var attack_timer: Timer = $hit_player

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")

	if not attack_timer.timeout.is_connected(_on_hit_player_timeout):
		attack_timer.timeout.connect(_on_hit_player_timeout)

func _physics_process(delta: float) -> void:
	deal_with_damage()
	update_health()

	if is_dead:
		velocity = Vector2.ZERO
		return

	if player_chase and player:
		var direction = (player.position - position).normalized()
		velocity = direction * SPEED
		if not is_attacking:
			play_walk_animation(direction)
	else:
		patrol_behavior(delta)

	move_and_slide()

func patrol_behavior(delta: float) -> void:
	patrol_change_timer += delta
	if patrol_change_timer >= 2.0 or velocity.length() < 1:
		patrol_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		patrol_change_timer = 0.0

	velocity = patrol_direction * SPEED * 0.5
	if not is_attacking:
		play_walk_animation(patrol_direction)

func play_walk_animation(dir: Vector2) -> void:
	if is_attacking:
		return
	if abs(dir.x) > abs(dir.y):
		$AnimatedSprite2D.play("Side_walk")
		$AnimatedSprite2D.flip_h = dir.x < 0
	elif dir.y > 0:
		$AnimatedSprite2D.play("Down_walk")
	else:
		$AnimatedSprite2D.play("Up_walk")

func play_attack_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		$AnimatedSprite2D.play("Side_attack")
		$AnimatedSprite2D.flip_h = dir.x < 0
	elif dir.y > 0:
		$AnimatedSprite2D.play("Down_attack")
	else:
		$AnimatedSprite2D.play("Up_attack")

func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	player = body
	player_chase = true
	await get_tree().create_timer(0.5).timeout

func _on_detection_area_body_exited(_body: Node2D) -> void:
	if is_dead:
		return
	player = null
	player_chase = false
	if not is_attacking:
		$AnimatedSprite2D.play("Idle")

func _on_minotaue_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.has_method("player"):
		player_inattack_zone = true
		if not attack_timer.is_stopped():
			attack_timer.stop()
		attack_timer.start()

func _on_minotaue_hitbox_body_exited(body: Node2D) -> void:
	if is_dead:
		return
	if body.has_method("player"):
		player_inattack_zone = false
		attack_timer.stop()
		if not is_attacking:
			$AnimatedSprite2D.play("Idle")

func _on_hit_player_timeout() -> void:
	if is_dead or not player_inattack_zone or is_attacking:
		return

	is_attacking = true

	if player:
		var attack_dir = (player.position - position).normalized()
		play_attack_animation(attack_dir)

	await get_tree().create_timer(0.4).timeout
	is_attacking = false

	if is_dead or not player_inattack_zone:
		return

	if Global.player_health > 0:
		Global.player_health -= 25

		if Global.player and Global.player.has_method("update_health"):
			Global.player.update_health()

		if Global.player and Global.player.has_method("take_hit_feedback"):
			Global.player.take_hit_feedback()

		if $player_hurt.playing:
			$player_hurt.stop()
		$player_hurt.play()
		if $AudioStreamPlayer.playing:
			$AudioStreamPlayer.stop()
		$AudioStreamPlayer.play()
func deal_with_damage():
	if is_dead:
		return
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage:
			health -= 10
			$take_damage_cooldown.start()
			can_take_damage = false
			print("Enemy health = ", health)

			if health <= 0:
				die()

			if $sword_sound.playing:
				$sword_sound.stop()
			$sword_sound.play()

func die():
	if is_dead:
		return
	is_dead = true
	emit_signal("died")
	$AnimatedSprite2D.play("Death")
	$CanvasLayer/ProgressBar2.hide()
	velocity = Vector2.ZERO
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	player_chase = false
	player_inattack_zone = false
	$CanvasLayer/ProgressBar2.hide()
	$"CanvasLayer/ChatGptImageJun8,2025,065808Pm".hide()
func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true

func update_health():
	var healthbar = $CanvasLayer/ProgressBar2
	healthbar.value = health

	var percent := float(health) / float(healthbar.max_value)
	var fill_color := Color("2ecc71")

	if percent < 0.6:
		fill_color = Color("f39c12")
	if percent < 0.3:
		fill_color = Color("e74c3c")
