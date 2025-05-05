class_name Town extends GameScene

@export var town_commands : UIGenericSelector

func _ready():
	start()

func start():
	$TownCanvas.show()
	super.start()
	town_commands.erase_commands()
	town_commands.add_command("Dialog", "dialog")
	town_commands.add_command("Battle", "battle")
	town_commands.add_command("Portrait", "portrait_edit")
	town_commands.add_command("Dungeon", "enter_dungeon")
	town_commands.add_command("Save", "save_game")
	main_loop()

func disable():
	$TownCanvas.hide()
	super.disable()

func main_loop() -> void:
	while true:
		print("aaa")
		var ret := await town_commands.start_select()
		print(ret)
		match ret.function:
			"dialog":
				await Game.debug_dialog()
			"battle":
				await Game.start_battle_test()
			"portrait_edit":
				await Game.start_portrait_edit(Game.game_data.party_front[0])
			"enter_dungeon":
				Game.start_dungeon()
				return
			"save_game":
				Game.save_data()
