extends Control



func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/players.tscn")


func _on_continue_game_button_pressed():
	pass # Продолжить игру


func _on_tutorial_button_pressed():
	pass # Отображение правил игры

# Выход из игры
func _on_exit_button_pressed():
	get_tree().quit()
