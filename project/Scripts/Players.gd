extends Control

# Пока что все кнопки ведут на одну и ту же сцену
# Игра с ботом
func _on_one_player_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn") 


func _on_two_players_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn") 


func _on_three_players_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn") 


func _on_four_players_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn") 
