extends Node

var allowed_scenes := ["Main Menu", "how_to"]
var delayed_scenes := { "segal": 2.0 }

var player: AudioStreamPlayer
var current_scene_name := ""
var delay_timer := 0.0
var delay_active := false

func _ready():
	player = $AudioStreamPlayer
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene_name = current_scene.name
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
	if scene_name in allowed_scenes:
		delay_active = false
		if not player.playing:
			player.play()
	elif scene_name in delayed_scenes:
		delay_timer = delayed_scenes[scene_name]
		delay_active = true
		if player.playing:
			player.stop() # dont Play Right Away
	else:
		delay_active = false
		if player.playing:
			player.stop()
