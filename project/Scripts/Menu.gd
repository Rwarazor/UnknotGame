extends Control

@onready var button_click_sound = $MarginContainer/VBoxContainer/ButtonClickSound

func _ready():
	$MarginContainer/VBoxContainer/ContinueGameButton.disabled = !FileAccess.file_exists("user://game.save")

func _on_new_game_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/players.tscn")


func _on_continue_game_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	Global.do_load = true
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_tutorial_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/rules.tscn")

func _on_settings_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")

# Выход из игры
func _on_exit_button_pressed():
	get_tree().quit()
