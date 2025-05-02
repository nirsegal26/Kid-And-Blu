extends Control

@onready var label_game_over: Label = $game_over
@onready var label_press_key: RichTextLabel = $LabelPressKey
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var full_text := "Game Over"
var typed_text := ""
var char_index := 0

func _ready() -> void:
	label_game_over.text = ""
	label_press_key.text = "Press any key to continue"
	label_press_key.hide() # Dont Show in Start
	$AudioStreamPlayer.play()

	animation_player.play("fade in")
	await animation_player.animation_finished

	await type_text()

	label_press_key.show()

# Typing Amination 
func type_text() -> void:
	for i in full_text.length():
		typed_text += full_text[i]
		label_game_over.text = typed_text
		await get_tree().create_timer(0.1).timeout
