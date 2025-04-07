class_name UIBattleActorContainer extends CenterContainer

signal selected(actors : Array[BattleActor])
signal canceled
signal exit

var front_actors : Array[BattleActor]
var back_actors : Array[BattleActor]

var grid : Container
var lines : Container

@export var front_container : Container
@export var back_container : Container

var selected_actors : Array[BattleActor]
var is_canceled : bool = false

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
		cancel_select_target()
		cancel_select_line()
		is_canceled = true
		exit.emit()

func add_actor_front(actor : BattleActor):
	front_container.add_child(actor)

func add_actor_back(actor : BattleActor):
	back_container.add_child(actor)

func erase_actors():
	for c in front_container.get_children():
		front_container.remove_child(c)
	for c in back_container.get_children():
		back_container.remove_child(c)

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
	var a : Array[BattleActor]
	for e in front_container.get_children():
		e = e as BattleActor
		if e && e.is_visible_in_tree(): a.append(e)
	return a

func get_actors_back() -> Array[BattleActor]:
	var a : Array[BattleActor]
	for e in back_container.get_children():
		e = e as BattleActor
		if e && e.is_visible_in_tree(): a.append(e)
	return a

func enable_target(allow_front := true, allow_back := true):
	var array : Array[BattleActor]
	if allow_front && allow_back: array = get_actors()
	elif allow_front: array = get_actors_front()
	else: array = get_actors_back()
	for e in array:
		e.selectable = true
		if !e.selected.is_connected(end_select_target):
			e.selected.connect(end_select_target)
		if !e.button.focus_entered.is_connected(on_change_focus):
			e.button.focus_entered.connect(on_change_focus)
		# 仮のフォーカス
		if e.button.is_visible_in_tree(): e.button.grab_focus()

func disable_target():
	for e in get_actors():
		e.selectable = false
		if e.selected.is_connected(end_select_target):
			e.selected.disconnect(end_select_target)
		if e.button.focus_entered.is_connected(on_change_focus):
			e.button.focus_entered.disconnect(on_change_focus)

func start_select_target(front := true, back := true) -> Array[BattleActor]:
	enable_target(front, back)
	# 前列1番目をフォーカス
	if !get_actors_front().is_empty():
		for a in get_actors_front():
			if a.button.is_visible_in_tree():
				a.button.grab_focus()
				break
	await exit
	return selected_actors

func end_select_target(actor : BattleActor):
	disable_target()
	var a : Array[BattleActor]
	a.append(actor)
	selected_actors = a
	is_canceled = false
	exit.emit()

func cancel_select_target():
	disable_target()

func start_select_line(allow_front := true, allow_back := true):
	for e in lines.get_children(): e.hide()
	lines.show()
	if allow_back && !get_actors_back().is_empty():
		var back : Button = lines.find_child("Back")
		if !back.pressed.is_connected(end_select_line_back):
			back.pressed.connect(end_select_line_back)
		back.show()
		back.grab_focus()
	if allow_front && !get_actors_front().is_empty():
		var front : Button = lines.find_child("Front")
		if !front.pressed.is_connected(end_select_line_front):
			front.pressed.connect(end_select_line_front)
		front.show()
		front.grab_focus()
	await exit
	return selected_actors

func end_select_line():
	var front : Button = lines.find_child("Front")
	front.hide()
	var back : Button = lines.find_child("Back")
	back.hide()

func cancel_select_line():
	end_select_line()

func end_select_line_front():
	end_select_line()
	selected_actors = get_actors_front()
	is_canceled = false
	exit.emit()

func end_select_line_back():
	end_select_line()
	selected_actors = get_actors_back()
	is_canceled = false
	exit.emit()

func pick_random(front : bool = true, back : bool = true) -> BattleActor:
	var array : Array[BattleActor]
	if front && back: array = get_actors()
	elif front: array = get_actors_front()
	elif back: array = get_actors_back()
	else: return null
	return array[DiceRoller.roll_dices(1, array.size()) - 1]
