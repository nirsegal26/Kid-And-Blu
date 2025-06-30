extends Node

var player: AudioStreamPlayer
var default_stream: AudioStream = null
var current_scene_name := ""
var delay_timer := 0.0
var delay_active := false

var allowed_scenes := ["Main Menu", "how_to", "segal", "win"]
var delayed_scenes := { "segal": 2.0 }

var loaded_streams := {}

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)
	player.volume_db = 0
	player.autoplay = true

	default_stream = _get_stream("res://music/FireredLeafgreen Opening and Title remix (mp3cut.net) (1).mp3")

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

func _get_stream(path: String) -> AudioStream:
	if loaded_streams.has(path):
		return loaded_streams[path]
	var stream = load(path)
	if stream:
		stream.loop = true
		loaded_streams[path] = stream
	return stream

func _check_scene_start(scene_name: String):
	print("Scene switched to:", scene_name)

	if scene_name == "10":
		delay_active = false
		var stream = _get_stream("res://music/final battle final.mp3")
		_switch_stream(stream)
		return

	if scene_name == "game_over":
		delay_active = false
		var stream = _get_stream("res://music/mix_4m00s (audio-joiner.com) (1).mp3")
		player.volume_db = 3
		_switch_stream(stream)
		return

	if scene_name in allowed_scenes:
		delay_active = false
		_switch_stream(default_stream)
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
			var stream = _get_stream("res://music/Pokémon GO OST - Halloween (Lavender Town) (mp3cut.net).mp3")
			_switch_stream(stream)
			return

	delay_active = false
	var stream = _get_stream("res://others/mix_38m04s (audio-joiner.com).mp3")
	_switch_stream(stream)

func _switch_stream(stream: AudioStream):
	if player.stream != stream:
		player.stop()
		player.stream = stream
	if not player.playing:
		player.play()
