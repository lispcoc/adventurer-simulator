extends Node2D

@export var speed = 400
var pf : Pathfinder
var gb : Gameboard

var target : Vector2i:
	set = set_target
var queued_target : Vector2i

var path : Array[Vector2i]
var moving : bool = false

func _ready() -> void:
	gb = $"..".gameboard
	print(gb.pixel_to_cell(position))
	pf =  Pathfinder.new($"../RoguelikeTest".get_used_cells(), gb)
	$Camera2D.make_current()

func set_target(v):
	target = v
	if not moving:
		request_move()

func request_move():
	moving = false
	var pos = gb.pixel_to_cell(position)
	var pos_pixel = gb.cell_to_pixel(pos)
	print(pos_pixel)
	path = pf.get_path_cells(pos, target)
	print(path)
	if path.size() > 1:
		moving = true
		print(Vector2(gb.cell_to_pixel(path[1])))
		var tw = create_tween()
		tw.tween_property(self, "position", Vector2(gb.cell_to_pixel(path[1])), 0.15 )
		tw.finished.connect(request_move)

func _get_move_direction() -> Vector2:
	return Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

func _unhandled_input(_event: InputEvent) -> void:
	var move_dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	if move_dir and not moving:
		if not is_zero_approx(move_dir.x):
			move_dir = Vector2(move_dir.x, 0)
		else:
			move_dir = Vector2(0, move_dir.y)
		target = gb.pixel_to_cell(position) + Vector2i(move_dir)
