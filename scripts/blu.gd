extends CharacterBody2D

var SPEED = 90.0
const ESCAPE_SPEED = 100.0
const MIN_DISTANCE = 20.0 # Min Distance From Player
const BUFFER_ZONE = 10.0
const SMOOTH_FACTOR = 0.2
var in_battle = false  # Checks If Player Is In Battle
var player: CharacterBody2D = null
var last_direction: Vector2 = Vector2.ZERO  # Saves The Last Direction
var player_dead = false  # var That Checks If Player Died

func _ready() -> void:
	player = get_node_or_null("../Player")  # Checks If Player Is Exists
	if player:
		if not player.battle_started.is_connected(_on_battle_started):
			player.battle_started.connect(_on_battle_started) # Connection To Battle
		if not player.player_died.is_connected(_on_player_died):
			player.player_died.connect(_on_player_died)  # Connection To Death
# Set Speed If Running
func set_run_speed(value: float) -> void:
	SPEED = value

# Main Player Is Dead Function
func _on_player_died():
	player_dead = true  # Signal That Player Is Dead
	in_battle = true  # Stop Movement 
	$AnimatedSprite2D.stop()
	await get_tree().create_timer(0.5).timeout
	$AnimatedSprite2D.play("Death")

# Player is In Battle
func _on_battle_started():
	in_battle = true
	$AnimatedSprite2D.stop() # Stop any Other Animation
	$AnimatedSprite2D.play("Worry") # Play Worry Animation
	await get_tree().create_timer(3.0).timeout # Play for 3 Seconds
	if not player_dead:
		in_battle = false  # If the Player Isn't Dead, The Battle Is Over


func _physics_process(_delta: float) -> void:
	# if The player is Dead, Change Nothing
	if player_dead:
		return
	
	# Movement After Player
	var distance_to_player = position.distance_to(player.position)
	var direction = (player.position - position).normalized()
	# Keep Min Distance
	if distance_to_player < MIN_DISTANCE:
		direction = (position - player.position).normalized()
		velocity = lerp(velocity, direction * ESCAPE_SPEED, SMOOTH_FACTOR)
	elif distance_to_player > MIN_DISTANCE + BUFFER_ZONE:
		velocity = lerp(velocity, direction * SPEED, SMOOTH_FACTOR)
	else:
		velocity = lerp(velocity, Vector2.ZERO, SMOOTH_FACTOR)

	move_and_slide()

	# If There's Movement, Keep Last Direction
	if velocity.length() > 5:
		last_direction = velocity.normalized()

	# If In Battle, Dont Play Movement Animation
	if in_battle:
		return
	
	# Update Animation, By Direction, If Not in Battle
	if velocity.length() > 5:
		if abs(velocity.x) > abs(velocity.y):
			$AnimatedSprite2D.play("RightWalk")
			$AnimatedSprite2D.flip_h = velocity.x < 0
		else:
			$AnimatedSprite2D.play("UpWalk" if velocity.y < 0 else "DownWalk")
			$AnimatedSprite2D.flip_h = false
	else:
		if abs(last_direction.x) > abs(last_direction.y):
			$AnimatedSprite2D.play("Right")
			$AnimatedSprite2D.flip_h = last_direction.x < 0
		else:
			$AnimatedSprite2D.play("Up" if last_direction.y < 0 else "Idle")
