extends Control

@onready var button_click_sound = $MarginContainer/ButtonClickSound
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

func _on_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/menu.tscn") 


func _on_repo_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	OS.shell_open("https://github.com/Rwarazor/UnknotGame")
