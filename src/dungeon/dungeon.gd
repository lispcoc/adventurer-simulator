@tool
class_name DungeonManager extends Node2D

signal loaded()
signal selected(selected_cell: Vector2i)

## The [Gameboard] object used to convert touch/mouse coordinates to game coordinates. The reference
## must be valid for the cursor to function properly.
@export var gameboard : Gameboard
@export var generator : DungeonGenerator
@export var dungeon_chip : Node2D
@export var dungeon_chip_frame : Node2D
@export var layer : TileMapLayer
@export var frame_layer : TileMapLayer

@export_tool_button("Run", "Callable") 
var btn1 = run

var map : DungeonGenerator.Array2D

var tileset : TileSet
var id_map : Dictionary
var pathfinder : Pathfinder

var width : int = 16
var height : int = 16
var tiles : Array[DungeonTile]

var player : Pawn

var handle_input := true

func _ready() -> void:
	tiles.resize(width * height)
	Game.battle_started.connect(func(): handle_input = false)
	Game.battle_ended.connect(func(): handle_input = true)
	run()

func run():
	generator.map_width = width
	generator.map_height = height
	layer.clear()
	var grass = dungeon_chip.find_child("Grass") as Node2D
	Script
	map = generator.generate()
	map.dump()
	for x in range(generator.map_width): for y in range(generator.map_height):
		if map.get_v(x, y): layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	for c in layer.get_used_cells():
		var tile : Node2D = grass.duplicate()
		set_tile(c, tile)
		set_dark(c, true)
	print(layer.get_used_cells())
	pathfinder =  Pathfinder.new(layer.get_used_cells(), gameboard)
	loaded.emit()

func set_tile(cell : Vector2i, tile : Node2D) -> void:
	tile.position = gameboard.cell_to_pixel(cell) - gameboard.cell_size / 2
	var frame = dungeon_chip_frame.duplicate()
	frame.position = gameboard.cell_to_pixel(cell) - gameboard.cell_size / 2
	layer.add_child(tile)
	frame_layer.add_child(frame)
	tiles[cell.y * width + cell.x] = DungeonTile.new(tile)

func get_tile(cell : Vector2i) -> DungeonTile:
	if cell.x > width or cell.x < 0 or cell.y > width or cell.y < 0: return null
	var idx = cell.y * width + cell.x
	if idx >= tiles.size(): return null
	return tiles[cell.y * width + cell.x]

func set_dark(cell : Vector2i, dark : bool) -> void:
	var tile := get_tile(cell)
	if tile: tile.set_dark(dark)

func set_player(pawn : Pawn):
	player = pawn
	player.on_move.connect(_on_player_move)
	_on_player_move(player.position)

func _on_player_move(position : Vector2):
	var cell = gameboard.pixel_to_cell(position)
	print(cell)
	for tile in tiles:
		if tile: tile.set_dark(true)
	for dx in range(-1, 2): for dy in range(-1, 2):
		var tile = get_tile(cell + Vector2i(dx, dy))
		if tile:
			tile.identified = true
			tile.set_dark(false)
	if randf() < 0.1:
		player.cancel_move()
		Game.start_battle()

func _input(event: InputEvent) -> void:
	if handle_input:
		if event is InputEventMouseMotion:
			get_viewport().set_input_as_handled()
		elif event.is_action_released("select"):
			get_viewport().set_input_as_handled()
			selected.emit(_get_cell_under_mouse())
			FieldEvents.cell_selected.emit(_get_cell_under_mouse())
			print(_get_cell_under_mouse())
			if player: player.target = _get_cell_under_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if handle_input:
		var move_dir := Vector2(
			Input.get_axis("ui_left", "ui_right"),
			Input.get_axis("ui_up", "ui_down")
		)
		if move_dir and not player.moving:
			if not is_zero_approx(move_dir.x): move_dir = Vector2(move_dir.x, 0)
			else: move_dir = Vector2(0, move_dir.y)
			player.target = gameboard.pixel_to_cell(player.position) + Vector2i(move_dir)

func _get_cell_under_mouse() -> Vector2i:
	# The mouse coordinates need to be corrected for any scale or position changes in the scene.
	var mouse_position: = ((get_global_mouse_position() - global_position) / global_scale)
	var cell_under_mouse = gameboard.pixel_to_cell(mouse_position)
	if not gameboard.boundaries.has_point(cell_under_mouse):
		cell_under_mouse = Gameboard.INVALID_CELL
	return cell_under_mouse

class DungeonTile:
	var node : Node2D
	var identified : bool = false

	func _init(_node) -> void:
		node = _node
	func set_dark(dark : bool):
		if dark:
			if identified:
				node.modulate = Color("gray")
			else:
				node.modulate = Color("black")
		else: node.modulate = Color("white")
