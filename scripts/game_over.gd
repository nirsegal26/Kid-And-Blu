extends Control

@onready var label_game_over: Label = $game_over
@onready var label_press_key: RichTextLabel = $LabelPressKey
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var full_text := "Game Over"
var typed_text := ""
var char_index := 0
var can_reset = false
func _ready() -> void:
	label_game_over.text = ""
	label_press_key.text = "Press any key to continue"
	label_press_key.hide()
	$AudioStreamPlayer.play()

	animation_player.play("fade in")
	await animation_player.animation_finished
	await type_text()
	label_press_key.show()

func type_text() -> void:
	for i in full_text.length():
		typed_text += full_text[i]
		label_game_over.text = typed_text
		await get_tree().create_timer(0.1).timeout
	can_reset = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and can_reset == true:
		startover()

func startover() -> void:
	if Global.last_scene_path != "":
		get_tree().change_scene_to_file(Global.last_scene_path)
	else:
		print("No scene to restart.")
