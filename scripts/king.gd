extends CharacterBody2D

var is_attacking := false  # Flag to prevent multiple attack overlaps
var SPEED = 50.0  # Movement speed
var player_chase = false  # Should enemy chase player?
var player : Node2D = null  # Reference to the player
var health = 500  # Enemy health
var player_inattack_zone = false  # Is player within attack zone?
var can_take_damage = true  # Damage cooldown flag
var is_dead = false  # Is enemy dead?
var patrol_direction := Vector2(1, 0)  # Initial patrol direction
var patrol_change_timer := 0.0  # Timer for switching patrol direction

@onready var attack_timer: Timer = $hit_player  # Timer to regulate attack rate

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")
	$ExclamationMark.hide()
	
	# Ensure attack_timer is connected once
	if not attack_timer.timeout.is_connected(_on_hit_player_timeout):
		attack_timer.timeout.connect(_on_hit_player_timeout)

func _physics_process(delta: float) -> void:
	deal_with_damage()
	update_health()

	if is_dead:
		velocity = Vector2.ZERO
		return

	# Move toward player if detected
	if player_chase and player:
		var direction = (player.position - position).normalized()
		velocity = direction * SPEED
		$AnimatedSprite2D.flip_h = player.position.x < position.x
	else:
		patrol_behavior(delta)

	move_and_slide()

# Triggered when player enters detection zone
func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	$ExclamationMark.show()
	$AnimatedSprite2D.play("Walk")
	player = body
	player_chase = true
	await get_tree().create_timer(0.5).timeout
	$ExclamationMark.hide()

# Triggered when player exits detection zone
func _on_detection_area_body_exited(_body: Node2D) -> void:
	if is_dead:
		return
	$AnimatedSprite2D.play("Idle")
	player = null
	player_chase = false

func minotaur():
	pass  # Unused placeholder

# Player enters attack zone
func _on_minotaue_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.has_method("player"):  # Check it's the actual player
		player_inattack_zone = true
		if not attack_timer.is_stopped():
			attack_timer.stop()
		attack_timer.start()

# Player leaves attack zone
func _on_minotaue_hitbox_body_exited(body: Node2D) -> void:
	if is_dead:
		return
	$AnimatedSprite2D.play("Walk")
	if body.has_method("player"):
		player_inattack_zone = false
		attack_timer.stop()

# Called when attack timer times out
func _on_hit_player_timeout() -> void:
	if is_dead or not player_inattack_zone or is_attacking:
		return

	print("Attacking!")  # Debug

	is_attacking = true
	$AnimatedSprite2D.play("Attack")

	# Delay before attack damage is applied
	await get_tree().create_timer(0.4).timeout 
	is_attacking = false

	if is_dead or not player_inattack_zone:
		return

	# Deal damage to player
	if Global.player_health > 0:
		Global.player_health -= (Global.player_take_damage + 10)

		if Global.player and Global.player.has_method("update_health"):
			Global.player.update_health()

		if Global.player and Global.player.has_method("take_hit_feedback"):
			Global.player.take_hit_feedback()

		if $player_hurt.playing:
			$player_hurt.stop()
		$player_hurt.play()

	# Resume walking animation if still chasing
	if player_chase and not is_dead:
		$AnimatedSprite2D.play("Walk")

# Handle being hit by the player
func deal_with_damage():
	if is_dead:
		return
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage:
			health -= Global.player_damage
			$take_damage_cooldown.start()
			can_take_damage = false
			print("Enemy health = ", health)

			if health <= 0:
				die()

			if $sword_sound.playing:
				$sword_sound.stop()
			$sword_sound.play()

# Called when enemy dies
func die():
	if is_dead:
		return
	is_dead = true
	$AnimatedSprite2D.play("Death")
	$ProgressBar2.hide()
	velocity = Vector2.ZERO
	set_physics_process(false)  # Stop all logic
	$CollisionShape2D.set_deferred("disabled", true)  # Disable collisions
	player_chase = false
	player_inattack_zone = false

	# Player rewards
	Global.red_count_coins += 1
	player.Level_up()
	player.update_coin_ui()
	player.red_add_coin()

# Called when damage cooldown ends
func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true

# Update the enemy's health bar
func update_health():
	var healthbar = $ProgressBar2
	healthbar.value = health
	var fill_style: StyleBoxFlat = healthbar.get_theme_stylebox("fill", "ProgressBar") as StyleBoxFlat
	if fill_style == null:
		fill_style = StyleBoxFlat.new()
		healthbar.add_theme_stylebox_override("fill", fill_style)
	fill_style.bg_color = Color(0.0, 0.0, 0)  # Black bar color

# Patrol logic when not chasing player
func patrol_behavior(delta: float) -> void:
	patrol_change_timer += delta
	# Change direction every 2s or if stuck
	if patrol_change_timer >= 2.0 or velocity.length() < 1:
		patrol_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		patrol_change_timer = 0.0

	velocity = patrol_direction * SPEED * 0.5
	$AnimatedSprite2D.play("Walk")
	$AnimatedSprite2D.flip_h = velocity.x < 0
