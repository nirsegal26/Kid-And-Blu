extends CharacterBody2D
@onready var coins_Label: Label = $CanvasLayer/coins_Label
@onready var red_coins_Label: Label = $CanvasLayer/red_coins_Label
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D2
@onready var dust_anim: AnimatedSprite2D = $AnimatedSprite2D2
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true
signal battle_started
var can_move = true
var attack_ip = false
var current_color: Color = Color.MEDIUM_SEA_GREEN
var target_color: Color = Color.MEDIUM_SEA_GREEN
var healthbar_flash_timer := 0.0
const WALK_SPEED := 75
const RUN_SPEED := WALK_SPEED * 1.4
const JUMP_VELOCITY = -400.0
var direct = "down"
signal player_died
var is_running = false
var max_health = Global.max_health
var damage = Global.player_take_damage

func _ready() -> void:
	Global.player = self

	health = Global.player_health # Saves Health By Global Var
	$AnimatedSprite2D.play("FrontIdle") # Defult Animation
	update_coin_ui() # Update Score
	Global.player = self 
	damage = Global.player_damage
	health = Global.player_health
	damage = Global.player_take_damage
	max_health = Global.max_health
	$CanvasLayer/level_label.text = str("LV.", Global.player_level)
	dust_anim.stop()
	$AnimatedSprite2D3.stop()
	$AnimatedSprite2D4.stop()
	$AnimatedSprite2D5.stop()

func _physics_process(delta: float) -> void:
	# If Dead
	if Global.player_health <= 0 and player_alive:
		print("Player died") # Debug
		player_alive = false
		can_move = false
		attack_ip = false # <–– עצור תקיפה מיידית
		Global.player_current_attack = false
		$deal_attack_timer.stop() # <–– עצור את הטיימר

	# עצור כל האנימציות האחרות
		$AnimatedSprite2D2.stop()
		$AnimatedSprite2D3.stop()
		$AnimatedSprite2D4.stop()
		$AnimatedSprite2D5.stop()
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.play("Death")
		$death.play()
		emit_signal("player_died")
		$death_timer.start()
		Engine.time_scale = 0.5
		set_physics_process(false)
		return



	player_movement(delta)
	attack()
	update_health()
	update_xp()

# Player Movement Function
func player_movement(_delta):
	var blu = get_node_or_null("res://scenes/blu.tscn") # Get Blu
	if blu and blu.has_method("set_run_speed"):
		blu.set_run_speed(RUN_SPEED + 2000 if is_running else 90) # Set the Speed Of Blu To Running

	if attack_ip: 
		return
	var is_running = Input.is_action_pressed("run")
	var speed = RUN_SPEED if is_running else WALK_SPEED

	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right") and can_move:
		velocity.x = speed
		direct = "right"
		play_animation(1, is_running)
	elif Input.is_action_pressed("ui_left") and can_move:
		velocity.x = -speed
		direct = "left"
		play_animation(1, is_running)
	elif Input.is_action_pressed("ui_down") and can_move:
		velocity.y = speed
		direct = "down"
		play_animation(1, is_running)
	elif Input.is_action_pressed("ui_up") and can_move:
		velocity.y = -speed
		direct = "up"
		play_animation(1, is_running)
	else:
		play_animation(0, false)

	move_and_slide()

	# Play \ Hide The Dust
	# Play Dust in the Left
	if is_running and (direct == "right"):
		# Stop the Other Ones
		$AnimatedSprite2D3.stop()
		$AnimatedSprite2D4.stop()
		$AnimatedSprite2D5.stop()
		if not dust_anim.is_playing():
			dust_anim.play("default")
	# Play Dust in the Right
	elif  is_running and (direct == "left"):
		# Stop the Other Ones
		dust_anim.stop()
		$AnimatedSprite2D4.stop()
		$AnimatedSprite2D5.stop()
		if not $AnimatedSprite2D3.is_playing():
			$AnimatedSprite2D3.play("default")
	elif is_running and (direct == "up"):
		# Stop the Other Ones
		dust_anim.stop()
		$AnimatedSprite2D3.stop()
		$AnimatedSprite2D5.stop()
		if not $AnimatedSprite2D4.is_playing():
			$AnimatedSprite2D4.play("default")
	elif is_running and (direct == "down"):
		# Stop the Other Ones
		dust_anim.stop()
		$AnimatedSprite2D3.stop()
		$AnimatedSprite2D4.stop()
		if not $AnimatedSprite2D5.is_playing():
			$AnimatedSprite2D5.play("default")
	# If Not Running Sides, Stop the Dust
	else:
		dust_anim.stop()
		$AnimatedSprite2D3.stop()
		$AnimatedSprite2D4.stop()
		$AnimatedSprite2D5.stop()

# Spawn the Dust Animation
func spawn_dust():
	if not dust_anim.is_playing():
		dust_anim.play("default")


# Animation Function (By Direction)
func play_animation(movement: int, is_running: bool):
	if attack_ip or not player_alive:  # Dont Change Animation While Attacking
		return
	var anim = $AnimatedSprite2D
	match direct:
		"right":
			anim.flip_h = false
			if movement == 1:
				anim.play("SideRun" if is_running else "SideWalk")
			else:
				anim.play("SideIdle")
		"left":
			anim.flip_h = true
			if movement == 1:
				anim.play("SideRun" if is_running else "SideWalk")
			else:
				anim.play("SideIdle")
		"down":
			anim.flip_h = true
			if movement == 1:
				anim.play("FrontRun" if is_running else "FrontWalk")
			else:
				anim.play("FrontIdle")
		"up":
			anim.flip_h = true
			if movement == 1:
				anim.play("BackRun" if is_running else "BackWalk")
			else:
				anim.play("BackIdle")


# For has_method Signal
func player():
	pass

# Enemy In Attack Range, Start Battle
func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("minotaur") or body.has_method("skeleton"):
		enemy_inattack_range = true
		emit_signal("battle_started")

# Enemy NOT in Attack Range, Stop Battle
func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("minotaur") or body.has_method("skeleton"):
		enemy_inattack_range = false

# Enemy is Attacking
func take_hit_feedback():
	$AnimatedSprite2D.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	$AnimatedSprite2D.modulate = Color.WHITE

# Attack Cooldown
func _on_attack_cooldown_timeout() -> void:
	if player_alive:
		enemy_attack_cooldown = true

# Attack Function
func attack():
	if not player_alive:
		return
	var dir = direct
	if Input.is_action_just_pressed("attack"):
		can_move = false
		await get_tree().create_timer(0.07).timeout
		Global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("SideAttack")
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("SideAttack")
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("FrontAttack")
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("BackAttack")
			$deal_attack_timer.start()
		if enemy_inattack_range == false:
			$sword_swing.play()
# Attack Finished Function
func _on_deal_attack_timer_timeout() -> void:
	if not player_alive:
		return
	$deal_attack_timer.stop()
	can_move = true # Can Move Again
	Global.player_current_attack= false
	attack_ip = false

# After Player Is Dead Function
func _on_death_timer_timeout() -> void:
	Global.last_scene_path = get_tree().current_scene.scene_file_path
	Engine.time_scale = 1 # Stop Slow-Mo
	get_tree().change_scene_to_file("res://scenes/game_over.tscn") # Reload The Scene
	Global.player_health = Global.max_health # With 100 Health
	Global.count_coins = 0 # Reset Kill Count
	Global.red_count_coins = 0

# HealthBar
func update_health():
	var healthbar = $CanvasLayer/healthbar
	healthbar.value = Global.player_health

	# Set Color
	if Global.player_health <= 20:
		target_color = Color.CRIMSON
	elif Global.player_health <= 50:
		target_color = Color.DARK_SEA_GREEN
	else:
		target_color = Color.MEDIUM_SEA_GREEN

	# Create The Color Style
	var fill_style: StyleBoxFlat = healthbar.get_theme_stylebox("fill", "ProgressBar") as StyleBoxFlat
	if fill_style == null:
		fill_style = StyleBoxFlat.new()
		healthbar.add_theme_stylebox_override("fill", fill_style)
	# Dont Go Over 100 Health
	if Global.player_health > Global.max_health:
		Global.player_health = Global.max_health

func _process(delta):
	update_healthbar_color(delta)

# Update HealtBar Color
func update_healthbar_color(delta):
	var healthbar = $CanvasLayer/healthbar
	var fill_style: StyleBoxFlat = healthbar.get_theme_stylebox("fill", "ProgressBar") as StyleBoxFlat
	if fill_style == null:
		return

	current_color = current_color.lerp(target_color, delta * 5.0)
	fill_style.bg_color = current_color

	# Flash When Health is Down
	if Global.player_health <= 20:
		healthbar_flash_timer += delta * 6.0  # Flashing Speed
		var alpha := 0.5 + 0.5 * sin(healthbar_flash_timer * PI)
		healthbar.modulate.a = alpha
	else:
		healthbar.modulate.a = 1.0
		healthbar_flash_timer = 0.0

# Count Coins Function
func add_coin():
	Global.xp += 1
	update_coin_ui()
	Level_up()

	
# Count Red Coins Function
func red_add_coin():
	Global.xp += 5

	
	update_coin_ui()
	Level_up()

# Update Score
func update_coin_ui():
	coins_Label.text = str(Global.count_coins)
	red_coins_Label.text = str(Global.red_count_coins)
	Level_up()


# Level Up Function
func Level_up():
	if Global.xp >= Global.max_xp:
		$AnimationPlayer.play("LevelUp")
		$level_up.play()
		Global.player_level += 1
		$CanvasLayer/level_label.text = str("LV." , Global.player_level)
		Global.max_health += 1
		Global.player_health += 5
		Global.player_take_damage -= 1
		Global.xp = 0
		Global.max_xp += 8
		Global.player_damage += 1

	

# Reset After Main Menu
func reset():
	Global.player_health = 100
	Global.max_health = 100
	Global.player_take_damage = 20
	Global.player_damage = 34
	
func update_xp():
	var xpbar = $CanvasLayer/xpbar
	xpbar.value = Global.xp
	xpbar.max_value = Global.max_xp 
