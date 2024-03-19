extends Node2D

@export var WIDTH_TILES = 20
@export var HEIGHT_TILES = 15
enum STATE {
	START_SELECTING_EDGES = 0,
	SELECTING_EDGES = 1,
	MOVING_EDGES = 2,
	CONFIRM_EDGES_MOVE = 3,

	SELECT_VERTEX = 10,
	CONFIRM_VERTEX = 11
}
var current_state = STATE.START_SELECTING_EDGES

@onready var unknoter = $UnknoterNode

func _on_back_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_switch_turn_mode_button_pressed() -> void:
	if current_state < STATE.SELECT_VERTEX:
		current_state = STATE.SELECT_VERTEX
		$UI/MarginContainer/VBoxContainer/HBoxContainer/Label.text = "Режим: вершина"
	else:
		current_state = STATE.START_SELECTING_EDGES
		$UI/MarginContainer/VBoxContainer/HBoxContainer/Label.text = "Режим: ребро"
	$EdgeTileMap.clear_all_selected_edges()
	$VertexTileMap.clear_all_selected_vertices()

func _ready() -> void:
	$VertexTileMap.reset(WIDTH_TILES, HEIGHT_TILES)
	$EdgeTileMap.reset(WIDTH_TILES, HEIGHT_TILES)

func is_edge_alt(edge: Vector2i) -> int:
	return edge[0] & 1

var current_selected_edge
var is_selected_edge_alt
var current_selected_offset
var current_perpindicular_offset

var current_hovered_edge
var is_hovered_edge_alt

var HOVERED_EDGE_SOURCE_ID = 2
var SELECTED_EDGE_SOURCE_ID = 4
var FUTURE_EDGE_SOURCE_ID = 6

func _draw_selected_edges(source_id):
	$EdgeTileMap.clear_all_selected_edges()
	var other_selected_edge = current_selected_edge
	if is_selected_edge_alt:
		other_selected_edge[1] += 2 * current_perpindicular_offset
	else:
		other_selected_edge[0] += 2 * current_perpindicular_offset
	$EdgeTileMap.draw_selected_edge(other_selected_edge, source_id)
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
			$EdgeTileMap.draw_selected_edge(other_selected_edge, source_id)
	if current_perpindicular_offset != 0:
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
		#begin_vertex[is_selected_edge_alt] += signn
		#end_vertex[is_selected_edge_alt] += signn
		for i in range(0, current_perpindicular_offset, signn):
			if is_selected_edge_alt:
				$EdgeTileMap.draw_selected_edge(begin_vertex + Vector2i(0, 2 * i + signn), FUTURE_EDGE_SOURCE_ID + 1 - is_selected_edge_alt)
				$EdgeTileMap.draw_selected_edge(end_vertex + Vector2i(0, 2 * i + signn), FUTURE_EDGE_SOURCE_ID + 1 - is_selected_edge_alt)
			else:
				$EdgeTileMap.draw_selected_edge(begin_vertex + Vector2i(2 * i + signn, 0), FUTURE_EDGE_SOURCE_ID + 1 - is_selected_edge_alt)
				$EdgeTileMap.draw_selected_edge(end_vertex + Vector2i(2 * i + signn, 0), FUTURE_EDGE_SOURCE_ID + 1 - is_selected_edge_alt)

# TODO: works weirdly when hovering out of bounds, maybe fix, pretty pls?
func _on_edge_hovered(edge: Vector2i) -> void:
	current_hovered_edge = edge
	is_hovered_edge_alt = is_edge_alt(edge)
	if current_state >= STATE.SELECT_VERTEX:
		return
	if current_state == STATE.START_SELECTING_EDGES:
		$EdgeTileMap.draw_selected_edge(edge, HOVERED_EDGE_SOURCE_ID + is_hovered_edge_alt)
	if current_state == STATE.SELECTING_EDGES:
		if is_selected_edge_alt:
			current_selected_offset = (edge[0] - current_selected_edge[0]) / 2
		else:
			current_selected_offset = (edge[1] - current_selected_edge[1]) / 2
		_draw_selected_edges(HOVERED_EDGE_SOURCE_ID + is_selected_edge_alt)

	if current_state == STATE.MOVING_EDGES:
		var new_perpendicular_offset
		if !is_selected_edge_alt:
			new_perpendicular_offset = (edge[0] - current_selected_edge[0]) / 2
		else:
			new_perpendicular_offset = (edge[1] - current_selected_edge[1]) / 2
		# TODO: if new_perpendicular_offset not valid move:
		#	return
		current_perpindicular_offset = new_perpendicular_offset
		_draw_selected_edges(SELECTED_EDGE_SOURCE_ID + is_selected_edge_alt)
	if current_state == STATE.CONFIRM_EDGES_MOVE:
		pass

func _on_edge_unhovered() -> void:
	if current_state == STATE.START_SELECTING_EDGES:
		$EdgeTileMap.clear_all_selected_edges()

func _on_edge_pressed(edge) -> void:
	if current_state == STATE.START_SELECTING_EDGES:
		#TODO: check with backend that it's our edge
		current_state = STATE.SELECTING_EDGES
		current_selected_edge = edge
		current_selected_offset = 0
		current_perpindicular_offset = 0
		is_selected_edge_alt = is_edge_alt(edge)
		$EdgeTileMap.draw_selected_edge(edge, HOVERED_EDGE_SOURCE_ID + is_selected_edge_alt)
	if current_state == STATE.MOVING_EDGES:
		current_state = STATE.CONFIRM_EDGES_MOVE
		#TODO: spawn confirm UI

func _on_edge_unpressed(edge) -> void:
	if current_state == STATE.SELECTING_EDGES:
		current_state = STATE.MOVING_EDGES
		_draw_selected_edges(SELECTED_EDGE_SOURCE_ID + is_selected_edge_alt)

var current_selected_vertex
var current_hovered_vertex

var HOVERED_VERTEX_SOURCE_ID = 1
var SELECTED_VERTEX_SOURCE_ID = 2

func _on_vertex_hovered(vertex: Vector2i) -> void:
	current_hovered_vertex = vertex
	# TODO: check with backend that we can change this vertex
	if current_state == STATE.SELECT_VERTEX:
		$VertexTileMap.draw_selected_vertex(vertex, HOVERED_VERTEX_SOURCE_ID)
	if current_state == STATE.CONFIRM_VERTEX:
		if current_hovered_vertex != current_selected_vertex:
			$VertexTileMap.draw_selected_vertex(vertex, HOVERED_VERTEX_SOURCE_ID)

func _on_vertex_unhovered() -> void:
	if current_state == STATE.SELECT_VERTEX:
		$VertexTileMap.clear_all_selected_vertices()
	if current_state == STATE.CONFIRM_VERTEX:
		if current_hovered_vertex != current_selected_vertex:
			$VertexTileMap.clear_selected_vertex(current_hovered_vertex)

func _on_vertex_pressed(vertex) -> void:
	# TODO: check with backend that we can change this vertex
	if current_state == STATE.SELECT_VERTEX:
		current_state = STATE.CONFIRM_VERTEX
		current_selected_vertex = vertex
		#TODO: create confirm UI
		$VertexTileMap.draw_selected_vertex(vertex, SELECTED_VERTEX_SOURCE_ID)

	if current_state == STATE.CONFIRM_VERTEX:
		$VertexTileMap.clear_selected_vertex(current_selected_vertex)
		current_selected_vertex = vertex
		$VertexTileMap.draw_selected_vertex(vertex, SELECTED_VERTEX_SOURCE_ID)

#TODO: add vertex confirm, send move to bavckend
