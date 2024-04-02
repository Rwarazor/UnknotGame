extends Control

@onready var button_click_sound = $MarginContainer/ButtonClickSound
func _on_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/menu.tscn") 
