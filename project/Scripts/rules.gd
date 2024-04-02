extends Control
@onready var button_click_sound = $ScrollContainer/VBoxContainer/ButtonClickSound

func _on_done_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
