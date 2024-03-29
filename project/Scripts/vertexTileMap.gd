extends TileMap

var widthTiles
var heightTiles

signal vertexHovered
signal vertexUnhovered
signal vertexPressed
signal vertexUnpressed

func vertex_to_tilemap_coords(coords: Vector2i) -> Vector2i:
	return Vector2i(
		(coords[0]  + coords[1]) / 2,
		widthTiles - coords[0] / 2  + coords[1] / 2
	)

func tilemap_to_vertex_coords(coords: Vector2i) -> Vector2i:
	return Vector2i(
		widthTiles + coords[0] - coords[1],
		coords[0] + coords[1] - widthTiles
	)

func is_tilemap_coords_actual_vertex(coords: Vector2i) -> bool:
	return (coords[0] + coords[1] + widthTiles + 1) & 1

func vertex_coords_out_of_bounds(coords: Vector2i) -> bool:
	return (
		coords[0] < 0 or
		coords[0] > 2 * widthTiles or
		coords[1] < 0 or
		coords[1] > 2 * heightTiles
	)

func reset(width: int, height: int) -> void:
	widthTiles = width
	heightTiles = height

func change_tile(layer, coords: Vector2i, source_id: int) -> void:
	var tile = vertex_to_tilemap_coords(coords)
	set_cell(layer, tile, source_id, Vector2i(0, 0), 0)

#func clear_selected_vertex(coords: Vector2i) -> void:
	#var tile = vertex_to_tilemap_coords(coords)
	#set_cell(1, tile)

var last_hovered_vertex = null

func _get_current_vertex():
	var tile = local_to_map(to_local(get_global_mouse_position()))
	var vertex = tilemap_to_vertex_coords(tile)
	if !is_tilemap_coords_actual_vertex(tile):
		vertex = null
	elif vertex_coords_out_of_bounds(vertex):
		vertex = null
	return vertex

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var vertex = _get_current_vertex()
		if vertex != last_hovered_vertex:
			if (last_hovered_vertex != null):
				emit_signal("vertexUnhovered", last_hovered_vertex)
			if (vertex != null):
				emit_signal("vertexHovered", vertex)
			last_hovered_vertex = vertex

	if event is InputEventMouseButton:
		var vertex = _get_current_vertex()
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if vertex != null:
					emit_signal("vertexPressed", vertex)
			else:
				emit_signal("vertexUnpressed", vertex)
