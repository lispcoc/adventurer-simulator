class_name Town extends GameScene

@export var town_commands : UIGenericSelector

func _ready():
	town_commands.add_command("Dialog", "dialog")
	town_commands.add_command("Battle", "battle")
	town_commands.add_command("Portrait", "portrait_edit")
	town_commands.add_command("Dungeon", "enter_dungeon")
	town_commands.add_command("Save", "save_game")
	main_loop()

func start():
	$TownCanvas.show()
	super.start()
	main_loop()

func disable():
	$TownCanvas.hide()
	super.disable()

func main_loop() -> void:
	var last_node : Control = null
	while true:
		town_commands.start_select()
		if last_node: last_node.grab_focus()
		await town_commands.exit
		last_node = Game.current_focus
		match town_commands.retvar.function:
			"dialog":
				await Game.debug_dialog()
			"battle":
				await Game.start_battle()
			"portrait_edit":
				await Game.start_portrait_edit(Game.game_data.party_front[0])
			"enter_dungeon":
				Game.start_dungeon()
				return
			"save_game":
				Game.save_data()
