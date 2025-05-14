extends Node2D
var hero = false
# קרב ומצלמה
var in_talking_area := false
var minotaurs := []
var camera_move := true
var enemy_move := true
var interact = true

@onready var camera_target_position := Vector2(834, 341)
@onready var wait_duration := 3.0
@onready var player := get_node_or_null("/root/Node2D/Player")
@onready var spacebar_anim: AnimationPlayer = $spacebar

# דיאלוג
var in_dialogue := false
var dialogue_index := 0
var is_typing := false
var typing_speed := 0.04
var current_typing_label: Label = null
var current_full_text := ""

var dialogue := [
	{ "speaker": "kid", "text": "who are you?" },
	{ "speaker": "blu", "text": "My name is Blu." },
	{ "speaker": "blu", "text": "They Got me.." },
	{ "speaker": "blu", "text": "those evil skeletons.." },
	{ "speaker": "kid", "text": "this evil.." },
	{ "speaker": "kid", "text": "i need to purge this forest," },
	{ "speaker": "kid", "text": "follow me." }
]

@onready var blu_label := $CanvasLayer/blu_talk
@onready var kid_label := $CanvasLayer/kid_talk
@onready var blu_anim := $blu_talk2
@onready var kid_anim := $kid_talk

func _ready() -> void:
	$Blu.set_physics_process(false)
	$Blu.velocity = Vector2.ZERO
	$Blu.get_node("AnimatedSprite2D").play("Worry")
	$Player.direct = "right"

	minotaurs = [
		$Minotaur,
		$Minotaur2,
		$Minotaur3,
		$Minotaur4,
		$Minotaur5
	]

	for minotaur in minotaurs:
		if minotaur.has_node("AnimatedSprite2D"):
			var sprite: AnimatedSprite2D = minotaur.get_node("AnimatedSprite2D")
			minotaur.set_physics_process(false)
			minotaur.velocity = Vector2.ZERO
			await get_tree().create_timer(0.2).timeout
			sprite.play("Idle")

	blu_label.text = ""
	kid_label.text = ""
	blu_label.hide()
	kid_label.hide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and enemy_move:
		enemy_move = false
		for minotaur in minotaurs:
			minotaur.set_physics_process(true)
			var sprite = minotaur.get_node("AnimatedSprite2D")
			if sprite and sprite.animation != "Walk":
				sprite.play("Walk")

func _on_fight_watch_area_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	if camera_move:
		camera_move = false
		player.set_physics_process(false)
		player.get_node("AnimatedSprite2D").play("FrontIdle")

		var camera: Camera2D = body.get_node_or_null("Camera2D")
		var original_position: Vector2 = camera.global_position
		var target_position: Vector2 = camera_target_position

		create_tween().tween_property(camera, "global_position", target_position, 2.0)
		await get_tree().create_timer(3.0).timeout
		$AnimationPlayer.play("new_animation")
		await get_tree().create_timer(2.0).timeout

		create_tween().tween_property(camera, "global_position", original_position, 2.0)
		player.set_physics_process(true)
		await get_tree().create_timer(1.0).timeout
		$AnimationPlayer.play("fade_away")

func _process(_delta: float) -> void:
	if in_talking_area and Global.player_level == 2 and not in_dialogue:
		if Input.is_action_just_pressed("interact"):
			in_dialogue = true
			dialogue_index = 0
			spacebar_anim.play("fade")
			show_next_line()
	elif in_dialogue:
		if Input.is_action_just_pressed("interact"):
			if is_typing:
				is_typing = false
				if current_typing_label:
					current_typing_label.text = current_full_text
			else:
				show_next_line()
	change_scenes()

func show_next_line():
	if dialogue_index >= dialogue.size():
		in_dialogue = false
		dialogue_index = 0
		blu_anim.play("fade")
		kid_anim.play("fade")
		blu_label.hide()
		kid_label.hide()

		# הפעלת Blu מחדש
		var blu = $Blu
		blu.set_physics_process(true)
		blu.get_node("AnimatedSprite2D").play("Idle") 
		blu.velocity = Vector2.ZERO
		$blu_talk.queue_free()
		hero = true
		return

	var line = dialogue[dialogue_index]
	dialogue_index += 1

	blu_label.hide()
	kid_label.hide()

	if line["speaker"] == "blu":
		blu_label.text = ""
		blu_label.show()
		current_typing_label = blu_label
		blu_anim.play("new_animation")
		kid_anim.play("fade")
	elif line["speaker"] == "kid":
		kid_label.text = ""
		kid_label.show()
		current_typing_label = kid_label
		kid_anim.play("new_animation")
		blu_anim.play("fade")

	current_full_text = line["text"]
	type_text(current_typing_label, current_full_text)

func type_text(label: Label, full_text: String) -> void:
	is_typing = true
	label.text = ""

	for i in full_text.length():
		if not is_typing:
			label.text = full_text
			break
		label.text += full_text[i]
		await get_tree().create_timer(typing_speed).timeout

	is_typing = false
	current_typing_label = null
	current_full_text = ""

func _on_blu_talk_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		in_talking_area = true
		if Global.player_level == 2:
			spacebar_anim.play("new_animation")

func _on_blu_talk_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_talking_area = false
		if not in_dialogue and Global.player_level == 2:
			spacebar_anim.play("fade")
			blu_anim.play("fade")
			kid_anim.play("fade")
			blu_label.hide()
			kid_label.hide()

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$AnimationPlayer.play("attackin")
		await get_tree().create_timer(2).timeout
		$AnimationPlayer.play("attackout")


func _on_advance_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player") and hero == true:
		Global.transition_scene = true
	elif body.has_method("player") and hero == false:
		$AnimationPlayer.play("hero_in")


func change_scenes():
	if  Global.transition_scene == true:
			get_tree().change_scene_to_file("res://scenes/2.tscn")
			Global.finish_changescene()


func _on_advance_scene_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		$AnimationPlayer.play("hero_out")
