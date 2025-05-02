extends Control

func _ready() -> void:
	$AnimationPlayer.play("show")

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
