extends Camera2D

var zoom_minimum
var zoom_maximum = 2.5
var zoom_speed = .1

var bounds: Vector4

func set_bounds(new_bounds: Vector4) -> void:
	var window_size = get_viewport_rect().size
	bounds = new_bounds
	zoom_minimum = max(window_size.x / (bounds[2] - bounds[0]), window_size.y / (bounds[3] - bounds[1]))

func clip_camera() -> void:
	var window_size = get_viewport_rect().size
	position.x = clamp(position.x, bounds[0], bounds[2] - window_size.x / zoom.x)
	position.y = clamp(position.y, bounds[1], bounds[3] - window_size.y / zoom.y)

# Update zoom only once per frame, because there was a bug when handling several
# zoom inputs in the same frame: updating zoom relies on mouse position,
# and changing zoom changes mouse position, but mouse position is (apparently)
# only updated once per frame.
func _process(delta: float) -> void:
	if delta_sum != 0:
		_change_zoom(delta_sum)
		delta_sum = 0

func _change_zoom(delta: float) -> void:
	var new_zoom = clamp(zoom.x + delta, zoom_minimum, zoom_maximum)
	var mouse_pos := get_global_mouse_position()
	zoom = Vector2(new_zoom, new_zoom)
	var new_mouse_pos := get_global_mouse_position()
	position += mouse_pos - new_mouse_pos
	clip_camera()

var delta_sum = 0
func change_zoom(delta: float) -> void:
	delta_sum += delta

var allow_dragging = false
var dragging = false

func _handle_zoom(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				change_zoom(-zoom_speed)
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				change_zoom(zoom_speed)
	if event is InputEventPanGesture:
		change_zoom(zoom_speed * event.delta[0])

func _handle_drag(event: InputEvent) -> void:
	if not allow_dragging:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				dragging = true
			else:
				dragging = false
	if event is InputEventMouseMotion and dragging:
		position = position - event.relative / zoom.x
		clip_camera()

# TODO: zoom to cursor
func _input(event: InputEvent) -> void:
	_handle_zoom(event)
	_handle_drag(event)
