extends CharacterBody2D

var SPEED = 50.0
var player_chase = false # Chase The Player
var player : Node2D = null 
var health = 100
var player_inattack_zone = false
var can_take_damage = true
var is_dead = false
var secondary_player : Node2D = null
var patrol_direction := Vector2(1, 0)  # Random First Movement Direction (Right)
var patrol_change_timer := 0.0

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")
	secondary_player = get_node_or_null("../Blu")  

	var main_player = get_node_or_null("/root/Node2D/Player")  
	if main_player and not main_player.player_died.is_connected(_on_main_player_died):
		main_player.player_died.connect(_on_main_player_died) 
	$ExclamationMark.hide()


func _physics_process(delta: float) -> void:
	deal_with_damage()  
	
	# First, Check If Dead
	if is_dead:
		velocity = Vector2.ZERO
		return
	# If Alive, and In Zone, The direction Wiil Be Towards Him
	if player_chase:
		var direction = (Global.player.position - position).normalized()
		velocity = direction * SPEED
		$AnimatedSprite2D.flip_h = Global.player.position.x < position.x
	else:
		patrol_behavior(delta)  # If Not in Zone, Random Movement

	move_and_slide()


# Player In Zone
func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.name != "Player":
		return # If Not Player, Do Nothing

	print("DETECTED: ", body.name)  # Debugging

	$ExclamationMark.show()
	$AnimatedSprite2D.play("Walk")
	player = body
	player_chase = true
	await get_tree().create_timer(0.5).timeout
	$ExclamationMark.hide()


# Player Left the Zone
func _on_detection_area_body_exited(body: Node2D) -> void:
	if is_dead:
		return
	if body.name == "Player":
		player = null
		player_chase = false


# For has_method Signal
func minotaur():
	pass


func _on_minotaue_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	# If The Body is Player, Attack
	if body.has_method("player"):
		$AnimatedSprite2D.play("Attack")
		player_inattack_zone= true

# Plyer Left HitBox Zone
func _on_minotaue_hitbox_body_exited(body: Node2D) -> void:
	if is_dead:
		return
	$AnimatedSprite2D.play("Walk")
	if body.has_method("player"):
		player_inattack_zone= false

# Self Damage Function
func deal_with_damage():
	if is_dead:
		return
	# If The Player In Attack
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			health = health - 100
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
	$AnimatedSprite2D.play("Death")
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	player_chase = false
	player_inattack_zone = false
	Global.count_coins += 1
	set_physics_process(false)

	if Global.player and Global.player.has_method("Level_up"):
		Global.player.Level_up()
		Global.player.update_coin_ui()
		Global.player.add_coin()


# Can Take Damage After Cooldown
func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
	
# Main Player Is Dead Function
func _on_main_player_died() -> void:
	# Main Player Died, Attack Blu
	if secondary_player:
		player = secondary_player
		player_chase = true
# Random Movement (Patrol) Function
func patrol_behavior(delta: float) -> void:
	patrol_change_timer += delta

	# Switch Direction Every 2 Seconds, or When Stuck
	if patrol_change_timer >= 2.0 or velocity.length() < 1:
		patrol_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		patrol_change_timer = 0.0

	# Enemy Movement
	velocity = patrol_direction * SPEED * 0.5  # Slower Than Chase
	$AnimatedSprite2D.play("Walk")
	$AnimatedSprite2D.flip_h = velocity.x < 0
