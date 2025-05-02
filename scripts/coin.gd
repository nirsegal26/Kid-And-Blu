extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var tween: Tween

func _ready():
	jump_effect()

func jump_effect():
	tween = get_tree().create_tween()

	var jump_height := 10.0
	var up_time := 0.12
	var down_time := 0.12
	var bounce_scale := Vector2(1.2, 0.8)

	var original_pos := position
	var peak_pos := original_pos - Vector2(0, jump_height)

	# קפיצה למעלה
	tween.tween_property(self, "position", peak_pos, up_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# התרחבות בקפיצה
	tween.parallel().tween_property(self, "scale", bounce_scale, up_time).set_trans(Tween.TRANS_SINE)

	# ירידה חזרה
	tween.tween_property(self, "position", original_pos, down_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# חזרה לקנה מידה רגיל
	tween.parallel().tween_property(self, "scale", Vector2(1,1), down_time).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node) -> void:
	if body.has_method("add_coin"):
		Global.count_coins += 1
		body.add_coin()
		animation_player.play("PickUp")
		print("Coins:", Global.count_coins)
		await animation_player.animation_finished
		queue_free()
