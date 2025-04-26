class_name UICommandSelector extends Container

@export var container : Container
@export var commands : Array[Button]
@export var cancelable : bool = false
@export var horizonal : bool = false

signal exit
@warning_ignore("unused_signal")
signal canceled

var retvar : Dictionary

func _ready() -> void:
	for cmd in commands:
		connect_command(cmd)
	hide()

func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		retvar["canceled"] = true
		exit.emit()

func connect_command(cmd : UICommand):
	cmd.selected.connect(on_selected)
	cmd.nested_entered.connect(disable)
	cmd.nested_canceled.connect(enable)

func disconnect_command(cmd : UICommand):
	cmd.selected.disconnect(on_selected)
	cmd.nested_entered.disconnect(disable)
	cmd.nested_canceled.disconnect(enable)

func erase_commands():
	for cmd in commands:
		disconnect_command(cmd)
		container.remove_child(cmd)
	commands.clear()

func add_command(text : String, variable : Dictionary):
	var cmd = UICommand.new()
	cmd.text = text
	cmd.variable = variable
	connect_command(cmd)
	commands.append(cmd)
	container.add_child(cmd)

func on_selected(variable : Dictionary):
	retvar = variable
	retvar["canceled"] = false
	exit.emit()
	
func on_change():
	pass

func start_select() -> Dictionary:
	retvar["canceled"] = false
	enable()
	show()
	await exit
	while retvar["canceled"] && !cancelable:
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
