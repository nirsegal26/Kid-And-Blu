extends Control

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	visible = false


func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()
	
func pause():
	get_tree().paused = true
	show()
	$AnimationPlayer.play("blur")

func testesc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		$AudioStreamPlayer.play()
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		$AudioStreamPlayer.play()
		resume()
		

func _on_resume_pressed() -> void:
	resume()

func _on_mainmenu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	Global.reset_game_state()


func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(_delta: float) -> void:
	testesc()
