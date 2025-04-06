class_name UIBattleActorContainer extends CenterContainer

signal selected(actors : Array[BattleActor])
signal canceled

var front_actors : Array[BattleActor]
var back_actors : Array[BattleActor]

var grid : Container
var lines : Container

@export var front_container : Container
@export var back_container : Container

var mode : Mode = Mode.None

enum Mode {
	None,
	SelectTarget,
	SelectLine,
}

func _ready() -> void:
	grid = find_child("GridV")
	lines = find_child("Lines")
	get_actors_front()
	front_container.minimum_size_changed.connect(on_grid_resized)
	back_container.minimum_size_changed.connect(on_grid_resized)

func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		if mode == Mode.SelectTarget:
			cancel_select_target()
		if mode == Mode.SelectLine:
			cancel_select_line()

func add_actor_front(actor : BattleActor):
	front_container.add_child(actor)

func add_actor_back(actor : BattleActor):
	back_container.add_child(actor)

func on_grid_resized():
	var front_button : Button = lines.find_child("Front")
	front_button.custom_minimum_size = front_container.size
	var back_button : Button = lines.find_child("Back")
	back_button.custom_minimum_size = back_container.size

func on_change_focus():
	return

func get_actors() -> Array[BattleActor]:
	return get_actors_front() + get_actors_back()

func get_actors_front() -> Array[BattleActor]:
	var a : Array[BattleActor] = []
	for e in front_container.get_children():
		a.append(e)
	return a

func get_actors_back() -> Array[BattleActor]:
	var a : Array[BattleActor] = []
	for e in back_container.get_children():
		a.append(e)
	return a

func enable_target():
	for e in get_actors():
		e.selectable = true
		if !e.selected.is_connected(end_select_target):
			e.selected.connect(end_select_target)
		if !e.button.focus_entered.is_connected(on_change_focus):
			e.button.focus_entered.connect(on_change_focus)
		e.button.grab_focus()

func disable_target():
	for e in get_actors():
		e.selectable = false
		if e.selected.is_connected(end_select_target):
			e.selected.disconnect(end_select_target)
		if e.button.focus_entered.is_connected(on_change_focus):
			e.button.focus_entered.disconnect(on_change_focus)

func start_select_target():
	enable_target()
	mode = Mode.SelectTarget
	if !get_actors_front().is_empty():
		get_actors_front()[0].focus()

func end_select_target(actor : BattleActor):
	print(actor)
	disable_target()
	mode = Mode.None
	var a : Array[BattleActor]
	a.append(actor)
	emit_signal("selected", a)

func cancel_select_target():
	disable_target()
	mode = Mode.None
	emit_signal("canceled")

func start_select_line():
	mode = Mode.SelectLine
	for e in lines.get_children(): e.hide()
	lines.show()
	if !get_actors_back().is_empty():
		var back : Button = lines.find_child("Back")
		if !back.pressed.is_connected(end_select_line_back):
			back.pressed.connect(end_select_line_back)
		back.show()
		back.grab_focus()
	if !get_actors_front().is_empty():
		var front : Button = lines.find_child("Front")
		if !front.pressed.is_connected(end_select_line_front):
			front.pressed.connect(end_select_line_front)
		front.show()
		front.grab_focus()

func end_select_line():
	var front : Button = lines.find_child("Front")
	front.hide()
	var back : Button = lines.find_child("Back")
	back.hide()
	mode = Mode.None

func cancel_select_line():
	end_select_line()
	mode = Mode.None
	emit_signal("canceled")

func end_select_line_front():
	print("end_select_line_front")
	end_select_line()
	emit_signal("selected", get_actors_front())

func end_select_line_back():
	print("end_select_line_back")
	end_select_line()
	emit_signal("selected", get_actors_back())
