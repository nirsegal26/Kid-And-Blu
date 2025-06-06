extends CharacterBody2D

var is_attacking := false  # Prevents overlapping attacks
var SPEED = 50.0  # Enemy movement speed
var player_chase = false  # Indicates whether to chase player
var player : Node2D = null  # Main player target
var health = 100  # Enemy health
var player_inattack_zone = false  # Is player within range for attack
var can_take_damage = true  # Cooldown flag for taking damage
var is_dead = false  # Enemy death state
var secondary_player : Node2D = null  # Fallback player reference (Blu)
var patrol_direction := Vector2(1, 0)  # Patrol direction
var patrol_change_timer := 0.0  # Timer for changing patrol direction

@onready var attack_timer: Timer = $hit_player  # Timer for attack intervals

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")
	secondary_player = get_node_or_null("../Blu")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

	# Ensure timer is connected to attack function
	if not attack_timer.timeout.is_connected(attack_player):
		attack_timer.timeout.connect(attack_player)

	# Connect death signal from main player
	var main_player = get_node_or_null("/root/Node2D/Player")
	if main_player and not main_player.player_died.is_connected(_on_main_player_died):
		main_player.player_died.connect(_on_main_player_died)

	$ExclamationMark.hide()

func _physics_process(delta: float) -> void:
	deal_with_damage()

	if is_dead:
		velocity = Vector2.ZERO
		return

	if player_chase:
		# Move toward the current target (main or secondary player)
		var direction = (Global.player.position - position).normalized()
		velocity = direction * SPEED
		$AnimatedSprite2D.flip_h = Global.player.position.x < position.x
	else:
		patrol_behavior(delta)

	move_and_slide()

# Triggered when player enters detection area
func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_dead or body.name != "Player":
		return

	print("DETECTED: ", body.name)
	$ExclamationMark.show()
	$AnimatedSprite2D.play("Walk")
	player = body
	player_chase = true
	await get_tree().create_timer(0.5).timeout
	$ExclamationMark.hide()

# Triggered when player exits detection area
func _on_detection_area_body_exited(body: Node2D) -> void:
	if is_dead:
		return
	if body.name == "Player":
		player = null
		player_chase = false

func minotaur():
	pass  # Placeholder function

# Player enters hitbox area
func _on_minotaue_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.has_method("player"):
		player_inattack_zone = true
		# Minimal delay ensures attack animation starts cleanly
		await get_tree().create_timer(0.000000000000001).timeout
		attack_player()
		attack_timer.start()

# Player exits hitbox area
func _on_minotaue_hitbox_body_exited(body: Node2D) -> void:
	if is_dead:
		return
	if body.has_method("player"):
		player_inattack_zone = false
		attack_timer.stop()
		if not is_attacking:
			$AnimatedSprite2D.play("Walk")

# Attack logic triggered by timer
func attack_player():
	if is_dead or not player_inattack_zone or is_attacking:
		return

	print("Attacking!")  # Debug info
	is_attacking = true
	$AnimatedSprite2D.play("Attack")

	if is_dead or not player_inattack_zone:
		return

	# Apply damage to player
	if Global.player_health > 0:
		Global.player_health -= Global.player_take_damage

		if Global.player and Global.player.has_method("update_health"):
			Global.player.update_health()

		if Global.player and Global.player.has_method("take_hit_feedback"):
			Global.player.take_hit_feedback()

		if $player_hurt.playing:
			$player_hurt.stop()
		$player_hurt.play()

# Called when any animation ends
func _on_animation_finished() -> void:
	# Reset attack flag after attack animation
	if $AnimatedSprite2D.animation == "Attack":
		is_attacking = false
		if player_chase:
			$AnimatedSprite2D.play("Walk")

# Process incoming damage from player attacks
func deal_with_damage():
	if is_dead:
		return
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage:
			health -= 100
			$take_damage_cooldown.start()
			can_take_damage = false
			print("Enemy health = ", health)

			if health <= 0:
				die()

			if $sword_sound.playing:
				$sword_sound.stop()
			$sword_sound.play()

# Death handler
func die():
	if is_dead:
		return

	is_dead = true
	$AnimatedSprite2D.play("Death")
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	player_chase = false
	player_inattack_zone = false
	Global.count_coins += 1
	set_physics_process(false)

	# Trigger player reward methods
	if Global.player and Global.player.has_method("Level_up"):
		Global.player.Level_up()
		Global.player.update_coin_ui()
		Global.player.add_coin()

# Reset damage cooldown flag
func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true

# Switch target to Blu if main player dies
func _on_main_player_died() -> void:
	if secondary_player:
		player = secondary_player
		player_chase = true

# Roaming behavior when not chasing player
func patrol_behavior(delta: float) -> void:
	patrol_change_timer += delta
	# Change direction every 2 seconds or if stuck
	if patrol_change_timer >= 2.0 or velocity.length() < 1:
		patrol_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		patrol_change_timer = 0.0

	velocity = patrol_direction * SPEED * 0.5
	$AnimatedSprite2D.play("Walk")
	$AnimatedSprite2D.flip_h = velocity.x < 0
