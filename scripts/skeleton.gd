extends CharacterBody2D

var SPEED = 50.0
var player_chase = false # Chase The Player
var player : Node2D = null 
var health = 100
var player_inattack_zone = false
var can_take_damage = true
var is_dead = false
var patrol_direction := Vector2(1, 0)  # Random First Movement Direction (Right)
var patrol_change_timer := 0.0

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")
	$ExclamationMark.hide()

func _physics_process(delta: float) -> void:
	deal_with_damage()  
	update_health()
# First, Check If Dead
	if is_dead:
		velocity = Vector2.ZERO
		return
	# If Alive, and In Zone, The direction Wiil Be Towards Him
	if player_chase and player:
		var direction = (player.position - position).normalized()
		velocity = direction * SPEED
		$AnimatedSprite2D.flip_h = player.position.x < position.x
	else:
		patrol_behavior(delta)  # If Not in Zone, Random Movement

	move_and_slide()

# Player In Zone
func _on_detection_area_body_entered(body: Node2D) -> void:
	# If The Player Is Dead, Do Nothing
	if is_dead:
		return
	# Else, Move
	$ExclamationMark.show()
	$AnimatedSprite2D.play("Walk")
	player = body
	player_chase = true
	await get_tree().create_timer(0.5).timeout
	$ExclamationMark.hide()

# Player Left the Zone
func _on_detection_area_body_exited(_body: Node2D) -> void:
	# If Player Is Dead, Do Nothing
	if is_dead:
		return
	$AnimatedSprite2D.play("Idle")
	player = null
	# Else, Dont Chase
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
			health = health - Global.player_damage
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
		return  # Prevent Double call For Death 

	is_dead = true
	$AnimatedSprite2D.play("Death")
	$ProgressBar2.hide()
	velocity = Vector2.ZERO
	set_physics_process(false)  # phycics_procces Function Update Prevention
	$CollisionShape2D.set_deferred("disabled", true)  # Disable Physics
	player_chase = false  # Stop Chase Player
	player_inattack_zone = false
	Global.red_count_coins += 1
	player.Level_up()
	player.update_coin_ui()
	player.red_add_coin()

# Can Take Damage After Cooldown
func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
	
func update_health():
	var healthbar = $ProgressBar2
	healthbar.value = health
	var fill_style: StyleBoxFlat = healthbar.get_theme_stylebox("fill", "ProgressBar") as StyleBoxFlat
	if fill_style == null:
		fill_style = StyleBoxFlat.new()
		healthbar.add_theme_stylebox_override("fill", fill_style)
	fill_style.bg_color = Color(0.2, 0.8, 0.2)  



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
