extends Control
@onready var choose_players_sound = $MarginContainer/ChoosePlayersSound
@onready var button_click_sound = $MarginContainer/ButtonClickSound

func _on_one_player_pressed():
	Global.players = 1
	Global.virtual_players = 1
	choose_players_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn") 


func _on_two_players_pressed():
	Global.players = 2
	Global.virtual_players = 1
	choose_players_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn") 

func _on_three_players_pressed():
	Global.players = 3
	Global.virtual_players = 0
	choose_players_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn") 

func _on_four_players_pressed():
	Global.players = 4
	Global.virtual_players = 0
	choose_players_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn") 

func _on_back_to_menu_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/menu.tscn") 
