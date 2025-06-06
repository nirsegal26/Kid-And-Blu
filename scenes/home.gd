extends Node2D
var run_label = true
var target_scene = ""

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
		target_scene = "home_inside"
		Global.transition_scene = true

# Can't Move Scene
func _on_enter_house_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		target_scene = ""
		Global.transition_scene = false

# Change Scene to home_inside
func change_scenes():
	if  Global.transition_scene == true:
		if target_scene == "home_inside":
			get_tree().change_scene_to_file("res://scenes/home_inside.tscn")
			Global.finish_changescene()
		elif target_scene == "blu_battle":
			get_tree().change_scene_to_file("res://scenes/blu_battle.tscn")
			Global.finish_changescene()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and run_label==true and not Input.is_action_pressed("run"):
		$AnimationPlayer.play("new_animation")
		await get_tree().create_timer(2).timeout
		$AnimationPlayer.play("fade_away")
		run_label = false 


func _on_blu_battle_area_body_entered(body: Node2D) -> void:
		if body.has_method("player"):
			target_scene = "blu_battle"
			Global.transition_scene = true
