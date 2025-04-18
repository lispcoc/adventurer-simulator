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

signal exit
@warning_ignore("unused_signal")
signal canceled

var commands : Array[UIGenericSelectorButton]
var retvar : Result = Result.new()

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
	hide()

func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		retvar.canceled = true
		exit.emit()

func get_button_width() -> int: return size.x / columns

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
		container.remove_child(cmd)
	commands.clear()

func add_command(text : String, function : String, args : Array = []):
	var cmd = UIGenericSelectorButton.new()
	cmd.text = text
	cmd.variable = Result.new()
	cmd.variable.function = function
	cmd.custom_minimum_size.x = get_button_width()
	if button_height: cmd.custom_minimum_size.y = button_height
	connect_command(cmd)
	commands.append(cmd)
	container.add_child(cmd)

func on_selected(variable : Result):
	retvar = variable
	retvar.canceled = false
	exit.emit()

func start_select() -> Result:
	retvar.canceled = false
	enable()
	show()
	container.position = (size - container.size) / 2
	await exit
	while retvar.canceled && !cancelable:
		await exit
	end_select()
	return retvar

func end_select():
	disable()
	hide()

func disable():
	for c in commands: c.disabled = true

func enable():
	if not commands.is_empty():
		for c in commands: c.disabled = false
		commands[0].grab_focus()
