extends Area2D

@onready var animated_sprite := $AnimatedSprite2D
@onready var life_timer := $life_timer
@onready var death_timer := $death_timer
@onready var collision_shape := $CollisionShape2D
var sound_timer := Timer.new()
@export var speed := 180.0
@export var attack_cooldown := 0.3
@export var attack_range := 20.0
@export var min_distance := 15.0

var target: Node2D = null
var is_dying := false
var can_attack := true
var last_direction := Vector2.ZERO  # כיוון תנועה אחרון

func _ready():
	target = get_node_or_null("/root/Node2D/Player")
	life_timer.start(30.0)  # חיים מקסימליים לעורב

func _physics_process(delta):
	if is_dying or target == null:
		return

	var dir = (target.global_position - global_position).normalized()
	last_direction = dir  # עדכון כיוון אחרון
	var distance = global_position.distance_to(target.global_position)

	# תזוזה לעבר השחקן רק אם לא קרוב מדי
	if distance > min_distance:
		position += dir * speed * delta

	# תקיפה רק אם בטווח וניתן
	if distance <= attack_range and can_attack:
		perform_attack(dir)
	elif distance > attack_range:
		update_fly_animation(dir)

	# זיהוי התקפה מהשחקן (גם בלי body_entered)
	if target.has_method("is_attacking") and target.is_attacking():
		if distance <= attack_range + 5.0:
			die()
	crow_sound()

func crow_sound():
	await get_tree().create_timer(30).timeout
	$AudioStreamPlayer2.play()


func update_fly_animation(dir: Vector2) -> void:
	if dir.y < -0.5:
		animated_sprite.play("UP")
	elif dir.y > 0.5:
		animated_sprite.play("DOWN")
	else:
		animated_sprite.play("FLY")
		animated_sprite.flip_h = dir.x < 0

func perform_attack(dir: Vector2):
	can_attack = false

	if dir.y < -0.5:
		animated_sprite.play("up_attack")
	elif dir.y > 0.5:
		animated_sprite.play("down_attack")
	else:
		animated_sprite.play("attack")
		animated_sprite.flip_h = dir.x < 0

	attack_and_reset()

func attack_and_reset() -> void:
	#await get_tree().create_timer(0.5).timeout

	if is_dying:
		return

	if is_instance_valid(target) and global_position.distance_to(target.global_position) <= attack_range + 10:
		Global.player_health -= 15
		Global.player.update_health()

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_body_entered(body: Node2D):
	if is_dying:
		return

	if body.name == "AttackArea":
		die()

func die():
	if is_dying:
		return

	is_dying = true
	can_attack = false
	collision_shape.set_deferred("disabled", true)

	# אנימציית מוות לפי כיוון אחרון
	if last_direction.y < -0.5:
		animated_sprite.play("die_up")
	elif last_direction.y > 0.5:
		animated_sprite.play("die_down")
	else:
		animated_sprite.play("die")

	death_timer.start(0.5)
	$AudioStreamPlayer2.play()
	
func _on_life_timer_timeout():
	queue_free()
	

func _on_death_timer_timeout():
	queue_free()
