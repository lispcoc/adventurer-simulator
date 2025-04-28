@tool
class_name DungeonGenerator extends TileMapLayer

@export var map_width := 16
@export var map_height := 16
@export var passable_probability := 0.3
@export var distance_factor := 5

@export_tool_button("Run", "Callable") 
var btn = run
@export_tool_button("Clear", "Callable") 
var btn2 = clear

var data : Array2D

const TILE_OUT_OF_RANGE = -1
const TILE_WALL = 0
const TILE_PASSABLE = 1
const TILE_START = 2
const TILE_GOAL = 3

const id_map : Dictionary = {
	TILE_WALL: -1,
	TILE_PASSABLE: 2,
	TILE_START: 3,
	TILE_GOAL: 6,
}

func run():
	print("run")
	set_cell(Vector2i(0, 0), 0,Vector2i(0, 0))
	print(get_used_cells())

func generate() -> Array2D:
	data = Array2D.new(map_width, map_height)
	fill(TILE_WALL)
	dig(0, 0)
	# 追加で穴を開ける
	for x in range(map_width): for y in range(map_height):
		if randf() < passable_probability:
			set_v(x, y, TILE_PASSABLE)
	# 適当な位置にスタートとゴールを設定
	var distance = Distance2D.new(data.filtered_points(TILE_PASSABLE))
	var max_dist = 0
	var candidate := data.filtered_points(TILE_PASSABLE)
	candidate.shuffle()
	var start_cell = candidate.front()
	var goal_cell = Vector2i(0, 0)
	candidate.pop_front()
	candidate = candidate.slice(0, distance_factor)
	for cell in candidate:
		var path = distance.get_path_cells(start_cell, cell)
		if max_dist <= path.size():
			max_dist = path.size()
			goal_cell = cell
	set_v(start_cell.x, start_cell.y, TILE_START)
	set_v(goal_cell.x, goal_cell.y, TILE_GOAL)
	return data

func dig(x := 0, y := 0):
	set_v(x, y, TILE_PASSABLE)
	var dir_list = [
		Vector2i(-1, 0),
		Vector2i(0, -1),
		Vector2i(1, 0),
		Vector2i(0, 1),
	]
	dir_list.shuffle()
	for dir in dir_list:
		if get_v(x + dir.x * 2, y + dir.y * 2) == TILE_WALL:
			set_v(x + dir.x, y + dir.y, TILE_PASSABLE)
			dig(x + dir.x * 2, y + dir.y * 2)

func get_v(x : int, y : int):
	return data.get_v(x, y)

func set_v(x : int, y : int, v : int):
	data.set_v(x, y, v)

func fill(v : int):
	data.fill(v)


class Array2D:
	var _width = 0
	var _height = 0
	var _pool = []
	const ARRAY_OUT_OF_RANGE = -1
	func _init(w:int, h:int) -> void:
		_width = w
		_height = h
		for j in range(h):
			for i in range(w):
				_pool.append(0)
	func fill(v:int) -> void:
		for j in range(_height):
			for i in range(_width):
				_pool[i + j * _width] = v
	func set_v(i:int, j:int, v:int) -> void:
		if i < 0 or i >= _width:
			return # 領域外
		if j < 0 or j >= _height:
			return # 領域外
		_pool[i + j * _width] = v
	func get_v(i:int, j:int) -> int:
		if i < 0 or i >= _width:
			return ARRAY_OUT_OF_RANGE # 領域外
		if j < 0 or j >= _height:
			return ARRAY_OUT_OF_RANGE # 領域外
		return _pool[i + j * _width]
	func dump() -> void:
		print("[array2d]")
		for j in range(_height):
			var s = ""
			for i in range(_width):
				s += "%d, "%get_v(i, j)
			print(s)
	func filtered_points(v : int) -> Array[Vector2i]:
		var a : Array[Vector2i]
		for j in range(_height): for i in range(_width):
			if get_v(i, j) == v: a.append(Vector2i(i, j))
		return a

class Distance2D extends AStar2D:
	func _init(cells : Array[Vector2i]):
		for c in cells:
			add_point_and_connect(get_available_point_id(), c)

	func add_point_and_connect(id : int, pos : Vector2, scale : float = 1.0 ):
		super.add_point(id, pos, scale)
		for id2 in get_point_ids():
			var pos2 = get_point_position(id2)
			if id != id2 and (pos - pos2).length() <= 1.0:
				connect_points(id, id2)

	func get_path_cells(src : Vector2, dst : Vector2) -> PackedVector2Array:
		var src_id : int = -1
		var dst_id : int = -1
		for id in get_point_ids():
			var pos = get_point_position(id)
			if pos == src:
				src_id = id
			elif pos == dst:
				dst_id = id
			if src_id > -1 and dst_id > -1: break
		if src_id > -1 and dst_id > -1:
			return get_point_path(src_id, dst_id)
		return []
