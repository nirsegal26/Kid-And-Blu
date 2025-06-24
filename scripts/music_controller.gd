extends Node

var player: AudioStreamPlayer
var default_stream: AudioStream
var game_stream = preload("res://others/mix_38m04s (audio-joiner.com).mp3") as AudioStreamMP3
var halloween_stream = preload("res://music/Pokémon GO OST - Halloween (Lavender Town) (mp3cut.net).mp3") as AudioStreamMP3
var final_battle_stream = preload("res://music/final_battle.mp3") as AudioStreamMP3
var main_theme = preload("res://music/FireredLeafgreen Opening and Title remix (mp3cut.net) (1).mp3") as AudioStreamMP3
var game_over = preload("res://music/mix_4m00s (audio-joiner.com) (1).mp3") as AudioStreamMP3
var allowed_scenes := ["Main Menu", "how_to", "segal","win"]
var delayed_scenes := { "segal": 2.0 }

var current_scene_name := ""
var delay_timer := 0.0
var delay_active := false

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)
	player.volume_db = 0
	player.autoplay = true

	# שים את main_theme כברירת מחדל לסצנות המורשות
	default_stream = main_theme

	# הפעל לולאה לכל המוזיקות
	game_stream.loop = true
	halloween_stream.loop = true
	final_battle_stream.loop = true
	main_theme.loop = true
	game_over.loop = true
	
	if get_tree().current_scene:
		current_scene_name = get_tree().current_scene.name
		_check_scene_start(current_scene_name)

func _process(delta):
	var new_scene = get_tree().current_scene
	if new_scene == null:
		return

	var new_scene_name = new_scene.name
	if new_scene_name != current_scene_name:
		current_scene_name = new_scene_name
		_check_scene_start(new_scene_name)

	if delay_active:
		delay_timer -= delta
		if delay_timer <= 0.0:
			delay_active = false
			if not player.playing:
				player.play()

func _check_scene_start(scene_name: String):
	print("Scene switched to:", scene_name)

	if scene_name == "10":
		delay_active = false
		if player.stream != final_battle_stream:
			player.stop()
			player.stream = final_battle_stream
		if not player.playing:
			player.play()
		return

	if scene_name == "game_over":
		delay_active = false
		if player.stream != game_over:
			player.stop()
			player.stream = game_over
			player.volume_db = 3
		if not player.playing:
			player.play()
		return

	if scene_name in allowed_scenes:
		delay_active = false
		if player.stream != default_stream:
			player.stop()
			player.stream = default_stream
		if not player.playing:
			player.play()
		return

	if scene_name in delayed_scenes:
		delay_timer = delayed_scenes[scene_name]
		delay_active = true
		if player.playing:
			player.stop()
		return

	if scene_name.is_valid_int():
		var scene_number = int(scene_name)
		if scene_number >= 6:
			delay_timer = 1.0
			delay_active = true
			if player.stream != halloween_stream:
				player.stop()
				player.stream = halloween_stream
			return

	delay_active = false
	if player.stream != game_stream:
		player.stop()
		player.stream = game_stream
	if not player.playing:
		player.play()
