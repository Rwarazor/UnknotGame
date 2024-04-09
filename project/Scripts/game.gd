extends Node2D

@export var WIDTH_TILES: int
@export var HEIGHT_TILES: int

@export var ZOOM_BORDERS_INFLATE_X = 500
@export var ZOOM_BORDERS_INFLATE_Y = 500

@onready var button_click_sound = $UI/ButtonClickSound

enum STATE {
	DRAG = -1,

	START_SELECTING_EDGES = 0,
	SELECTING_EDGES = 1,
	MOVING_EDGES = 2,
	CONFIRM_EDGES_MOVE = 3,

	SELECT_VERTEX = 10,
	CONFIRM_VERTEX = 11
}
var current_state = STATE.DRAG

var current_player = 0

@onready var unknoter = $UnknoterNode

var EDGE_TILE_COLOR = 3
var EDGE_TILE_HOVERED = 5
var EDGE_TILE_SELECTED = 7
var FUTURE_EDGE_SOURCE_ID = 9

var VERTEX_TILE_COLOR = 0
var VERTEX_TILE_HOVERED = 1
var VERTEX_TILE_SELECTED = 2

func _refresh_state():
	_clear_edge_tiles()
	_clear_vertex_tiles()
	$Zoom.allow_dragging = (current_state == STATE.DRAG)
	
func _on_back_to_menu_button_pressed():
	button_click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_node("CanvasLayer/PausedMenu")._is_paused = !get_node("CanvasLayer/PausedMenu")._is_paused

func _on_save() -> void:
	_save()

func _on_edge_button_pressed():
	button_click_sound.play()
	current_state = STATE.START_SELECTING_EDGES
	_refresh_state()
	
func _on_vertex_button_pressed():
	button_click_sound.play()
	current_state = STATE.SELECT_VERTEX
	_refresh_state()
	
func _on_move_button_pressed():
	current_state = STATE.DRAG
	button_click_sound.play()
	_refresh_state()

func _on_cancel_button_pressed():
	if current_state == STATE.CONFIRM_EDGES_MOVE:
		current_state = STATE.START_SELECTING_EDGES
	else:
		current_state = STATE.SELECT_VERTEX

func _on_confirm_button_pressed():
	current_state = STATE.DRAG
	if current_player < Global.players:
		current_player +=1
	else: 
		current_player = 1
	_update_labels(current_player, 1, player_colors[current_player - 1])
	$UI/MarginContainer/HBoxContainer/CancelButton.visible = false
	$UI/MarginContainer/HBoxContainer/ConfirmButton.visible = false

var player_colors = []
var game_colors = [Color(0,1,1,1), Color(1,0,1,1), Color(1,1,0,1), Color(0.486275, 0.988235, 0, 1)]

func _update_labels(player: int, energy: int, color: Color):
	$UI/MarginContainer/VBoxContainer2/PlayerLabel.text = str("Игрок №", player)
	$UI/MarginContainer/VBoxContainer2/EnergyLabel.text = str("Энергии: ", energy)
	$UI/MarginContainer/VBoxContainer2/PlayerLabel.add_theme_color_override("font_color", color)
	$UI/MarginContainer/VBoxContainer2/EnergyLabel.add_theme_color_override("font_color", color)

func _save() -> void:
	$UnknoterNode.set_current_player(current_player)
	$UnknoterNode.save("user://game.save")

func _load() -> void:
	$UnknoterNode.load("user://game.save")
	WIDTH_TILES = $UnknoterNode.get_width()
	HEIGHT_TILES = $UnknoterNode.get_height()
	Global.players = $UnknoterNode.get_players()
	current_player = $UnknoterNode.get_current_player()

func _ready() -> void:
	if Global.do_load:
		Global.do_load = false
		_load()
	else:
		$UnknoterNode.reset(Global.players, WIDTH_TILES, HEIGHT_TILES)
		
	$UI/MarginContainer/HBoxContainer/CancelButton.visible = false
	$UI/MarginContainer/HBoxContainer/ConfirmButton.visible = false
	$VertexTileMap.reset(WIDTH_TILES, HEIGHT_TILES)
	$EdgeTileMap.reset(WIDTH_TILES, HEIGHT_TILES)
	_on_move_button_pressed()
	var field_bounds = $VertexTileMap.get_field_bounds()
	var inflate = Vector4(
		-ZOOM_BORDERS_INFLATE_X,
		-ZOOM_BORDERS_INFLATE_Y,
		ZOOM_BORDERS_INFLATE_X,
		ZOOM_BORDERS_INFLATE_Y
	)
	$Zoom.set_bounds(field_bounds + inflate)

	for player in range(Global.players):
		var color = game_colors[randf_range(0, 4)]
		while player_colors.has(color):
			color = game_colors[randf_range(0, 4)]
		player_colors.push_back(color)
		$EdgeTileMap.add_layer(1 + player)
		$EdgeTileMap.set_layer_modulate(1 + player, color)
		$VertexTileMap.add_layer(player)
		$VertexTileMap.set_layer_modulate(player, color)

	for x in range(0, 2 * WIDTH_TILES + 1):
		for y in range(0, 2 * HEIGHT_TILES + 1):
			if (x & 1) and (y & 1):
				continue
			if (x + y) & 1:
				var player = $UnknoterNode.get_edge_player(x, y)
				if player != -1:
					var edge = Vector2i(x, y)
					$EdgeTileMap.change_tile(1 + player, edge, EDGE_TILE_COLOR + is_edge_alt(edge))
			else:
				var upper = $UnknoterNode.get_upper_vertex_player(x, y)
				if upper != -1:
					$VertexTileMap.change_tile(upper, Vector2i(x, y), VERTEX_TILE_COLOR)
	_update_labels(current_player + 1, 2, player_colors[current_player])
func is_edge_alt(edge: Vector2i) -> int:
	return edge[0] & 1

var current_selected_edge
var is_selected_edge_alt
var current_selected_offset
var current_perpindicular_offset

var current_hovered_edge
var is_hovered_edge_alt

var changed_edge_tiles = []

func _clear_edge_tiles():
	for tile in changed_edge_tiles:
		var edge = tile[0]
		var was_ours = tile[1]
		if was_ours:
			$EdgeTileMap.change_tile(1 + current_player, edge, EDGE_TILE_COLOR + is_edge_alt(edge))
		else:
			$EdgeTileMap.change_tile(1 + current_player, edge, -1)
	changed_edge_tiles = []

func _change_edge_tile(edge: Vector2i, source_id: int):
	$EdgeTileMap.change_tile(1 + current_player, edge, source_id)
	var was_ours = $UnknoterNode.get_edge_player(edge[0], edge[1]) == current_player
	changed_edge_tiles.push_back([edge, was_ours])

func _draw_selected_edges():
	_clear_edge_tiles()
	var other_selected_edge = current_selected_edge
	if is_selected_edge_alt:
		other_selected_edge[1] += 2 * current_perpindicular_offset
	else:
		other_selected_edge[0] += 2 * current_perpindicular_offset
	var source_id = EDGE_TILE_HOVERED if current_state == STATE.SELECTING_EDGES else EDGE_TILE_SELECTED
	source_id += is_selected_edge_alt
	_change_edge_tile(other_selected_edge, source_id)
	if current_selected_offset != 0:
		var signn = sign(current_selected_offset)
		for i in range(signn, current_selected_offset + signn, signn):
			other_selected_edge = current_selected_edge
			if is_selected_edge_alt:
				other_selected_edge[0] += 2 * i
				other_selected_edge[1] += 2 * current_perpindicular_offset
			else:
				other_selected_edge[0] += 2 * current_perpindicular_offset
				other_selected_edge[1] += 2 * i
			_change_edge_tile(other_selected_edge, source_id)
	if current_perpindicular_offset != 0:
		_change_edge_tile(current_selected_edge, -1)
		if current_selected_offset != 0:
			var signn = sign(current_selected_offset)
			for i in range(signn, current_selected_offset + signn, signn):
				other_selected_edge = current_selected_edge
				if is_selected_edge_alt:
					other_selected_edge[0] += 2 * i
				else:
					other_selected_edge[1] += 2 * i
				_change_edge_tile(other_selected_edge, -1)
		var begin_vertex = current_selected_edge
		begin_vertex[0] = begin_vertex[0] / 2 * 2
		begin_vertex[1] = begin_vertex[1] / 2 * 2
		var end_vertex = current_selected_edge
		end_vertex[0] = (end_vertex[0] + 1) / 2 * 2
		end_vertex[1] = (end_vertex[1] + 1) / 2 * 2
		if current_selected_offset < 0:
			begin_vertex[1 - is_selected_edge_alt] += 2 * current_selected_offset
		if current_selected_offset > 0:
			end_vertex[1 - is_selected_edge_alt] += 2 * current_selected_offset
		var signn = sign(current_perpindicular_offset)
		for i in range(0, current_perpindicular_offset, signn):
			if is_selected_edge_alt:
				_change_edge_tile(begin_vertex + Vector2i(0, 2 * i + signn), FUTURE_EDGE_SOURCE_ID + 1 - is_selected_edge_alt)
				_change_edge_tile(end_vertex + Vector2i(0, 2 * i + signn), FUTURE_EDGE_SOURCE_ID + 1 - is_selected_edge_alt)
			else:
				_change_edge_tile(begin_vertex + Vector2i(2 * i + signn, 0), FUTURE_EDGE_SOURCE_ID + 1 - is_selected_edge_alt)
				_change_edge_tile(end_vertex + Vector2i(2 * i + signn, 0), FUTURE_EDGE_SOURCE_ID + 1 - is_selected_edge_alt)

# TODO: works weirdly when hovering out of bounds, maybe fix, pretty pls?
func _on_edge_hovered(edge: Vector2i) -> void:
	current_hovered_edge = edge
	is_hovered_edge_alt = is_edge_alt(edge)
	if current_state >= STATE.SELECT_VERTEX:
		return
	if current_state == STATE.START_SELECTING_EDGES:
		_clear_edge_tiles()
		if $UnknoterNode.get_edge_player(edge[0], edge[1]) != current_player:
			return
		_change_edge_tile(edge, EDGE_TILE_HOVERED + is_hovered_edge_alt)
	if current_state == STATE.SELECTING_EDGES:
		var next_selected_offset
		if is_selected_edge_alt:
			next_selected_offset = (edge[0] - current_selected_edge[0]) / 2
		else:
			next_selected_offset = (edge[1] - current_selected_edge[1]) / 2
		if not $UnknoterNode.can_player_shift_edges(
				current_player,
				current_selected_edge[0],
				current_selected_edge[1],
				next_selected_offset,
				0):
			return
		current_selected_offset = next_selected_offset
		_draw_selected_edges()

	if current_state == STATE.MOVING_EDGES:
		$UI/MarginContainer/HBoxContainer/CancelButton.visible = true
		var new_perpendicular_offset
		if !is_selected_edge_alt:
			new_perpendicular_offset = (edge[0] - current_selected_edge[0]) / 2
		else:
			new_perpendicular_offset = (edge[1] - current_selected_edge[1]) / 2
		if new_perpendicular_offset == 0:
			return
		if not $UnknoterNode.can_player_shift_edges(
				current_player,
				current_selected_edge[0],
				current_selected_edge[1],
				current_selected_offset,
				new_perpendicular_offset):
			return
		current_perpindicular_offset = new_perpendicular_offset
		_draw_selected_edges()
	if current_state == STATE.CONFIRM_EDGES_MOVE:
		pass

func _on_edge_unhovered() -> void:
	if current_state == STATE.START_SELECTING_EDGES:
		_clear_edge_tiles()

func _on_edge_pressed(edge) -> void:
	if current_state == STATE.START_SELECTING_EDGES:
		if $UnknoterNode.get_edge_player(edge[0], edge[1]) != current_player:
			return
		current_state = STATE.SELECTING_EDGES
		current_selected_edge = edge
		is_selected_edge_alt = is_edge_alt(current_selected_edge)
		current_selected_offset = 0
		current_perpindicular_offset = 0
		_change_edge_tile(edge, EDGE_TILE_HOVERED + is_selected_edge_alt)
	if current_state == STATE.MOVING_EDGES:
		$UI/MarginContainer/HBoxContainer/CancelButton.visible = true
		if current_perpindicular_offset == 0:
			return
		current_state = STATE.CONFIRM_EDGES_MOVE
		$UI/MarginContainer/HBoxContainer/CancelButton.visible = true
		$UI/MarginContainer/HBoxContainer/ConfirmButton.visible = true

func _on_edge_unpressed(edge) -> void:
	if current_state == STATE.SELECTING_EDGES:
		current_state = STATE.MOVING_EDGES
		$UI/MarginContainer/HBoxContainer/CancelButton.visible = true
		_draw_selected_edges()

var changed_vertex_tiles = []

func _clear_vertex_tiles():
	for tile in changed_vertex_tiles:
		var vertex = tile[0]
		var player = tile[1]
		$VertexTileMap.change_tile(player, vertex, VERTEX_TILE_COLOR)
	changed_vertex_tiles = []

func _change_vertex_tile(vertex: Vector2i, source_id: int):
	var upper = $UnknoterNode.get_upper_vertex_player(vertex[0], vertex[1])
	$VertexTileMap.change_tile(upper, vertex, source_id)
	changed_vertex_tiles.push_back([vertex, upper])

var current_selected_vertex

func _can_flip_vertex(vertex: Vector2i) -> bool:
	return $UnknoterNode.can_player_flip_vertex(current_player, vertex[0], vertex[1])

func _on_vertex_hovered(vertex: Vector2i) -> void:
	if not _can_flip_vertex(vertex):
		return
	if current_state == STATE.SELECT_VERTEX:
		_change_vertex_tile(vertex, VERTEX_TILE_HOVERED)
	if current_state == STATE.CONFIRM_VERTEX:
		if vertex == current_selected_vertex:
			return
		_change_vertex_tile(vertex, VERTEX_TILE_HOVERED)

func _on_vertex_unhovered(vertex: Vector2i) -> void:
	if current_state == STATE.SELECT_VERTEX:
		_clear_vertex_tiles()
	if current_state == STATE.CONFIRM_VERTEX:
		_clear_vertex_tiles()
		_change_vertex_tile(current_selected_vertex, VERTEX_TILE_SELECTED)

func _on_vertex_pressed(vertex) -> void:
	if not _can_flip_vertex(vertex):
		return
	if current_state == STATE.SELECT_VERTEX or current_state == STATE.CONFIRM_VERTEX:
		current_state = STATE.CONFIRM_VERTEX
		current_selected_vertex = vertex
		$UI/MarginContainer/HBoxContainer/CancelButton.visible = true
		$UI/MarginContainer/HBoxContainer/ConfirmButton.visible = true
		_clear_vertex_tiles()
		_change_vertex_tile(vertex, VERTEX_TILE_SELECTED)

