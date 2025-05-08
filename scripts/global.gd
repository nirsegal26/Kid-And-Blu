extends Node

var last_scene_path: String = ""
var red_count_coins = 0
var player_current_attack = false
var count_coins = 0
var current_scene = "home_inside"
var transition_scene = false
var player_exit_cliffside_posx = 329.0
var player_exit_cliffside_posy = 167.0
var player_start_posx = 329.0
var player_start_posy = 131.0
var game_first_loadin = true
var player_health: int = 100
var player_level = 1
var player_damage = 34
var xp = 0
var max_xp = 5
var previous_scene: String = ""
var previous_player_position: Vector2 = Vector2.ZERO
var player: Node = null
var player_take_damage = 20
var max_health = 100

func _ready():
	if not Global.player:
		Global.player = get_node_or_null("/root/Node2D/Player")

func update_current_scene(new_scene_name: String) -> void:
	current_scene = new_scene_name
	
func finish_changescene():
	if transition_scene:
		transition_scene = false
	
# Scene Update
	if current_scene == "home_inside":
		current_scene = "home"
	elif current_scene == "home":
		current_scene = "home_inside"

# Reset State
func reset_game_state():
	player_health = 100
	player_damage = 34
	player_level = 1
	xp = 0
	max_xp = 5
	count_coins = 0
	red_count_coins = 0
