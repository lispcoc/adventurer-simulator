class_name UIGenericSelector extends ScrollContainer

class Result:
	var function : String
	var args : Array
	var canceled : bool

@export var container : GridContainer = null
@export var columns : int = 1
@export var button_height : int
@export var proto_commands : Array[UIGenericSelectorButton]
@export var cancelable : bool = false
@export var horizonal : bool = false
@export var hide_inactive : bool = true
@export var info_line : bool = false

signal exit
@warning_ignore("unused_signal")
signal canceled

var commands : Array[UIGenericSelectorButton]
var retvar : Dictionary
var processing : bool = false

var last_node : Control = null

func _ready() -> void:
	if !container:
		container = GridContainer.new()
		container.columns = columns
		add_child(container)
	for cmd in proto_commands:
		add_command(cmd.text, cmd.variable.function, [])
	#if horizonal:
	#	commands.back().focus_neighbor_right = commands.front().get_path()
	#	commands.front().focus_neighbor_left = commands.back().get_path()
	#else:
	#	commands.back().focus_neighbor_bottom = commands.front().get_path()
	#	commands.front().focus_neighbor_top = commands.back().get_path()
	if hide_inactive: hide()

func _unhandled_input(_event: InputEvent) -> void:
	if not processing:
		return
	if Input.is_action_pressed("ui_cancel"):
		if cancelable:
			retvar.canceled = true
			on_canceled()
			get_viewport().set_input_as_handled()

func get_button_width() -> int: return int(size.x / columns)

func connect_command(cmd : UIGenericSelectorButton):
	cmd.selected.connect(on_selected)
	cmd.nested_entered.connect(disable)
	cmd.nested_canceled.connect(enable)

func disconnect_command(cmd : UIGenericSelectorButton):
	cmd.selected.disconnect(on_selected)
	cmd.nested_entered.disconnect(disable)
	cmd.nested_canceled.disconnect(enable)

func erase_commands():
	for cmd in commands:
		disconnect_command(cmd)
	commands.clear()
	for c in container.get_children(): container.remove_child(c)

func add_command(text : String, function : String, args : Array = [], focus_callback : Callable = func ():, info : Array[Control] = []):
	var cmd = UIGenericSelectorButton.new()
	cmd.text = text
	cmd.variable = {}
	cmd.variable.function = function
	cmd.variable.args = args
	cmd.custom_minimum_size.x = get_button_width()
	cmd.focus_entered.connect(focus_callback)
	if button_height: cmd.custom_minimum_size.y = button_height
	connect_command(cmd)
	commands.append(cmd)
	container.add_child(cmd)
	if info_line:
		for i in columns - 1:
			if info.size() > i: container.add_child(info[i])
			else: container.add_child(Label.new())

func on_selected(variable : Dictionary):
	retvar = variable.duplicate()
	retvar.canceled = false
	last_node = Game.current_focus
	end_select()

func on_canceled():
	if cancelable:
		retvar.canceled = true
		end_select()

func start_select() -> Dictionary:
	retvar.canceled = false
	enable()
	show()
	processing = true
	if last_node: last_node.grab_focus()
	await exit
	return retvar

func end_select():
	processing = false
	disable()
	if hide_inactive: hide()
	exit.emit()

func disable():
	for c in commands: c.disabled = true

func enable():
	if not commands.is_empty():
		for c in commands: c.disabled = false
		commands[0].grab_focus()

static func parse_retval(retval : Dictionary) -> Result:
	var res = Result.new()
	if retval.has("function"): res.function = retval["function"]
	if retval.has("args"): res.args = retval["args"]
	if retval.has("canceled"): res.canceled = retval["canceled"]
	return res
