extends Control
@onready var choose_players_sound = $MarginContainer/ChoosePlayersSound

# Пока что все кнопки ведут на одну и ту же сцену
# Игра с ботом
func _on_one_player_pressed():
	Global.players = 1
	choose_players_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn") 


func _on_two_players_pressed():
	Global.players = 2
	choose_players_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn") 


func _on_three_players_pressed():
	Global.players = 3
	choose_players_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn") 


func _on_four_players_pressed():
	Global.players = 4
	choose_players_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn") 
