extends Control

@onready var button_click_sound = $ButtonClickSound


func _on_back_to_menu_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_new_game_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_exit_button_pressed():
	get_tree().quit()
