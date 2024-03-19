extends TileMap

var widthTiles
var heightTiles

signal edgeHovered
signal edgeUnhovered
signal edgePressed
signal edgeUnpressed

func edge_to_tilemap_coords(coords: Vector2i) -> Vector2i:
	return Vector2i(
		coords[0] / 2 + coords[1] / 2,
		widthTiles - (coords[0] + 1) / 2 + coords[1] / 2
	)

func tilemap_to_edge_coords(coords: Vector2i) -> Vector2i:
	return Vector2i(
		(widthTiles + coords[0] - coords[1]),
		(coords[0] + coords[1] - widthTiles + 1)
	)

func edge_coords_out_of_bounds(coords: Vector2i) -> bool:
	return (
		coords[0] < 0 or
		coords[0] > widthTiles * 2 or
		coords[1] < 0 or
		coords[1] > heightTiles * 2
	)

func edge_is_horizontal(coords: Vector2i) -> int:
	return coords[0] & 1

func reset(width: int, height: int) -> void:
	widthTiles = width
	heightTiles = height
	for x in range(1, 2 * widthTiles, 2):
		for y in range(0, 2 * heightTiles + 1, 2):
			set_cell(0, edge_to_tilemap_coords(Vector2i(x, y)), 1, Vector2i(0, 0), 0)

	for x in range(0, 2 * widthTiles + 1, 2):
		for y in range(1, 2 * heightTiles, 2):
			set_cell(0, edge_to_tilemap_coords(Vector2i(x, y)), 0, Vector2i(0, 0), 0)

func draw_selected_edge(coords: Vector2i, source_id: int) -> void:
	var tile = edge_to_tilemap_coords(coords)
	set_cell(1, tile, source_id, Vector2i(0, 0), 0)

func clear_selected_edge(coords: Vector2i) -> void:
	var tile = edge_to_tilemap_coords(coords)
	set_cell(1, tile)

func clear_all_selected_edges() -> void:
	clear_layer(1)

var last_hovered_edge = null

func get_current_edge():
	var tile = local_to_map(to_local(get_global_mouse_position()))
	var edge = tilemap_to_edge_coords(tile)
	if edge_coords_out_of_bounds(edge):
		edge = null
	return edge

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var edge = get_current_edge()
		if edge != last_hovered_edge:
			if last_hovered_edge != null:
				emit_signal("edgeUnhovered")
			if edge != null:
				emit_signal("edgeHovered", edge)
			last_hovered_edge = edge
	if event is InputEventMouseButton:
		var edge = get_current_edge()
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if edge != null:
					emit_signal("edgePressed", edge)
			else:
				emit_signal("edgeUnpressed", edge)
