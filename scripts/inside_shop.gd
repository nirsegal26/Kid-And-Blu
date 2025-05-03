extends Control

var current_typing_label: Label = null
var current_full_text: String = ""
var dialogue_finished := false

# Store Labels in Variants
@onready var labels := [
	$Label1,
	$Label2,
	$Label3,
	$Label4,
	$Label5,
	$Label6,
]

@onready var label7: Label = $Label7
@onready var label8: Label = $Label8

var current_label_index := 0
var typing_speed := 0.05
var is_typing := false

func _ready() -> void:
	$AnimationPlayer2.play("new_animation") # Fade In
	$AnimationPlayer.play("default") # play store Animation
	# Hide the Labels
	for label in labels:
		label.hide()
	label7.hide()
	label8.hide()
	$AnimationPlayer3.play("arrow") # Arrow Animation
	# Hide the Buttons
	$yes.hide()
	$no.hide()
	$armour.hide()
	$sword.hide()
	$health.hide()
	
	show_next_label()

# Spacebar Function
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_SPACE:
		if is_typing:
			is_typing = false
			if current_typing_label:
				current_typing_label.text = current_full_text
		else:
			show_next_label()


# Next Sentence Function
func show_next_label():
	if dialogue_finished:
		return  # Do Nothing if Dialogue is Over

	if current_label_index > 0 and current_label_index < labels.size():
		labels[current_label_index - 1].hide()

	if current_label_index >= labels.size():
		$yes.show()
		$no.show()
		dialogue_finished = true # Dialogue Ends Here
		return

	var label: Label = labels[current_label_index]
	var full_text: String = label.text
	label.text = ""
	label.show()
	await type_text(label, full_text)
	current_label_index += 1


# Typing Animation
func type_text(label: Label, full_text: String) -> void:
	is_typing = true
	current_typing_label = label
	current_full_text = full_text
	label.text = ""
	
	for i in full_text.length():
		if not is_typing:
			label.text = full_text
			break
		label.text += full_text[i]
		await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false
	current_typing_label = null
	current_full_text = ""


func _on_yes_pressed() -> void:
	if Global.player_health > Global.max_health*0.5:
		$AnimationPlayer3.stop()
		$IcArrowDropDown36Px_svg.hide()
		$Label6.hide()
		$yes.hide()
		$no.hide()
	
		label7.text = ""  # Clear Text
		label7.show()
		await type_text(label7, "great, which one would you like to upgrade?")

		$armour.show()
		$sword.show()
		$health.show()
	
	else:
		$AnimationPlayer3.stop()
		$IcArrowDropDown36Px_svg.hide()
		$Label6.hide()
		$yes.hide()
		$no.hide()
	
		label7.text = ""  # Clear Text
		label7.show()
		await type_text(label7, "you have less than 50% hp!   ")
		return_to_previous_scene()

func _on_no_pressed() -> void:
	$Label6.hide()
	$yes.hide()
	$no.hide()
	label8.show()
	await type_text(label8, "get out!   ")
	return_to_previous_scene()

func return_to_previous_scene():
	if Global.previous_scene != "":
		get_tree().change_scene_to_file(Global.previous_scene)


func _on_back_pressed() -> void:
	return_to_previous_scene()


func _on_armour_pressed() -> void:
	label8.hide()
	label7.hide()
	$Label9.show()
	$stats.play("def")
	await type_text($Label9,"ha ha ha! great choice!   ")
	Global.player_health *= 0.5
	Global.player_take_damage -= 5
	return_to_previous_scene()


func _on_sword_pressed() -> void:
	label8.hide()
	label7.hide()
	$Label9.show()
	$stats.play("attack")
	await type_text($Label9,"ha ha ha! great choice!   ")
	Global.player_health *= 0.5
	Global.player_damage += 7
	return_to_previous_scene()


func _on_health_pressed() -> void:
	label8.hide()
	label7.hide()
	$Label9.show()
	$stats.play("health")
	await type_text($Label9,"ha ha ha! great choice!   ")
	Global.player_health *= 0.5
	Global.max_health += 15
	return_to_previous_scene()
