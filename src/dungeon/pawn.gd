class_name Pawn extends Node2D

signal on_move

@export var speed = 400
var pf : Pathfinder
var gb : Gameboard
var manager : DungeonManager

var target : Vector2i:
	set = set_target
var queued_target : Vector2i

var h_dir : int = 1
var v_dir : int = 1
@export var sprite : Sprite2D

var path : Array[Vector2i]
var moving : bool = false
var is_active : bool = false

func _ready() -> void:
	manager = get_parent() as DungeonManager
	if manager:
		manager.loaded.connect(start)

func start():
	gb = manager.gameboard
	pf = manager.pathfinder
	print(gb.pixel_to_cell(position))
	$Camera2D.make_current()
	is_active = true
	manager.set_player(self)

func set_target(v):
	target = v
	if not moving:
		request_move()

func get_cell():
	return gb.pixel_to_cell(position)

func cancel_move():
	target = gb.pixel_to_cell(position)

func request_move():
	if not is_active: return
	moving = false
	var pos = gb.pixel_to_cell(position)
	path = pf.get_path_cells(pos, target)
	if path.size() > 1:
		moving = true
		var target_next = path[1]
		var dir = target_next - pos
		if dir.x: h_dir = dir.x
		if dir.y: v_dir = dir.y
		sprite.flip_h = h_dir > 0
		var tw = create_tween()
		tw.tween_property(self, "position", Vector2(gb.cell_to_pixel(target_next)), 0.15 )
		tw.finished.connect(func(): on_move.emit(position))
		tw.finished.connect(request_move)
		tw = create_tween()
		tw.tween_property(sprite, "position", sprite.position - Vector2(0, 8), 0.15 / 2.0 )
		tw.tween_property(sprite, "position", sprite.position, 0.15 / 2.0 )

func _unhandled_input(_event: InputEvent) -> void:
	if not is_active: return
