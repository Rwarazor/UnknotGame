extends Camera2D

var zoom_minimum = Vector2(.1, .1)
var zoom_maximum = Vector2(2.5, 2.5)
var zoom_speed = Vector2(.1, .1)

# TODO: zoom to cursor
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom -= zoom_speed
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom += zoom_speed
	if event is InputEventPanGesture:
		zoom += zoom_speed * event.delta
	zoom[0] = max(zoom[0], zoom_minimum[0])
	zoom[1] = max(zoom[1], zoom_minimum[1])
	zoom[0] = min(zoom[0], zoom_maximum[0])
	zoom[1] = min(zoom[1], zoom_maximum[1])
