extends Node2D

func _ready():
	if Global.previous_player_position != Vector2.ZERO:
		global_position = Global.previous_player_position
	Global.update_current_scene("home")  
	Global.game_first_loadin = false


func _process(_delta: float) -> void:
	change_scenes()
	
# Open The House Door
func _on_opendoorarea_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		$AnimatedSprite2D.play("open")

# Close The House Door
func _on_opendoorarea_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		$AnimatedSprite2D.play("close")

# Can Move Scene
func _on_enter_house_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = true

# Can't Move Scene
func _on_enter_house_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = false

# Change Scene to home_inside
func change_scenes():
	if  Global.transition_scene == true:
		if Global.current_scene == "home":
			get_tree().change_scene_to_file("res://scenes/home_inside.tscn")
			Global.finish_changescene()
