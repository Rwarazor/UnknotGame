extends Camera2D

var zoom_minimum = Vector2(.1, .1)
var zoom_maximum = Vector2(2.5, 2.5)
var zoom_speed = Vector2(.1, .1)

# TODO: zoom to cursor
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if zoom > zoom_minimum:
					zoom -= zoom_speed
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if zoom < zoom_maximum:
					zoom += zoom_speed
