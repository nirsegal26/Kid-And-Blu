extends Node2D

var skeletons := []
var enemy_move := true
var princes := []
var enemy_move2 := true

func _ready() -> void:
	skeletons = [
		$Minotaur,
		$Minotaur2,
		$Minotaur3,
		$Minotaur4,
		$Minotaur5,
		$Minotaur6,
		$Minotaur7,
		$Minotaur8,
		$Minotaur9,
		$Minotaur10,
		$Minotaur11,
		$Minotaur12,
		$Minotaur13,
		$Minotaur14,
		$Minotaur15,
		$Minotaur16,
		$Minotaur17,
		$Skeleton,
		$Skeleton2,
		$Skeleton3,
		$Skeleton4,
		$Skeleton5,
		$Skeleton6
	]
	princes = [
		$Prince,
		$Prince2
	]
	freeze_enemies()
	freeze_princes()




func freeze_princes():
	for prince in princes:
		if prince.has_node("AnimatedSprite2D"):
			var sprite: AnimatedSprite2D = prince.get_node("AnimatedSprite2D")

			# 1. כיבוי עיבוד פיזיקה
			prince.set_physics_process(false)

			# 2. כיבוי עיבוד רגיל (כמו process רגיל, אם יש)
			prince.set_process(false)

			# 3. נתק את כל האזורים שמזהים את השחקן
			for child in prince.get_children():
				if child is Area2D:
					child.set_monitoring(false)

			# 4. אפס מהירות (אם יש velocity)
			if "velocity" in prince:
				prince.velocity = Vector2.ZERO

			# 5. הפסק את כל הטיימרים (אם קיימים)
			for child in prince.get_children():
				if child is Timer:
					child.stop()

			# 6. נגן Idle
			sprite.play("Idle")

	
func freeze_enemies():
	for skeleton in skeletons:
		if skeleton.has_node("AnimatedSprite2D"):
			var sprite: AnimatedSprite2D = skeleton.get_node("AnimatedSprite2D")

			# 1. כיבוי עיבוד פיזיקה
			skeleton.set_physics_process(false)

			# 2. כיבוי עיבוד רגיל (כמו process רגיל, אם יש)
			skeleton.set_process(false)

			# 3. נתק את כל האזורים שמזהים את השחקן
			for child in skeleton.get_children():
				if child is Area2D:
					child.set_monitoring(false)

			# 4. אפס מהירות (אם יש velocity)
			if "velocity" in skeleton:
				skeleton.velocity = Vector2.ZERO

			# 5. הפסק את כל הטיימרים (אם קיימים)
			for child in skeleton.get_children():
				if child is Timer:
					child.stop()

			# 6. נגן Idle
			sprite.play("Idle")


func _on_det_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and enemy_move:
		$AudioStreamPlayer.play()
		unfreeze_enemies()
		enemy_move = false
		
		
func unfreeze_enemies():
	for skeleton in skeletons:
		if skeleton.has_node("AnimatedSprite2D"):
			var sprite: AnimatedSprite2D = skeleton.get_node("AnimatedSprite2D")

			# 1. הפעל עיבוד רגיל ופיזיקלי
			skeleton.set_process(true)
			skeleton.set_physics_process(true)

			# 2. הפעל את ה־Area2D אם יש (כדי לאפשר זיהוי שחקן)
			for child in skeleton.get_children():
				if child is Area2D:
					child.set_monitoring(true)

			# 3. הפעל טיימרים (אם יש)
			for child in skeleton.get_children():
				if child is Timer:
					child.start()

			# 4. נגן Idle או Run לפי הצורך (כאן Idle לדוגמה)
			sprite.play("Idle")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and enemy_move2:
		unfreeze_princes()
		enemy_move2 = false
		
func unfreeze_princes():
	for prince in princes:
		if prince.has_node("AnimatedSprite2D"):
			var sprite: AnimatedSprite2D = prince.get_node("AnimatedSprite2D")

			# 1. הפעל עיבוד רגיל ופיזיקלי
			prince.set_process(true)
			prince.set_physics_process(true)

			# 2. הפעל את ה־Area2D אם יש (כדי לאפשר זיהוי שחקן)
			for child in prince.get_children():
				if child is Area2D:
					child.set_monitoring(true)

			# 3. הפעל טיימרים (אם יש)
			for child in prince.get_children():
				if child is Timer:
					child.start()

			# 4. נגן Idle או Run לפי הצורך (כאן Idle לדוגמה)
			sprite.play("Idle")


func _on_open_door_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$AnimatedSprite2D.play("open")
		$open.play()

func _on_open_door_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$AnimatedSprite2D.play("close")
		$close.play()
