extends Control

@onready var button_click_sound = $ButtonClickSound
var _is_paused:bool = false:
	set = set_paused
	
func _unhandled_input(event) -> void:
	if event.is_action_pressed("pause"):
		_is_paused = !_is_paused
	
func set_paused(value:bool) -> void:
	_is_paused = value
	get_tree().paused = _is_paused
	visible = _is_paused
	


func _on_resume_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	_is_paused = false


func _on_menu_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")



func _on_quit_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()
