class_name Town extends CanvasLayer

@export var town_commands : UIGenericSelector

func _ready():
	town_commands.add_command("dialog", {"function": "dialog"})
	town_commands.add_command("battle", {"function": "battle"})
	town_commands.add_command("portrait", {"function": "portrait_edit"})
	town_commands.add_command("aaaaaa", {})
	town_commands.add_command("aaaaaa", {})
	main_loop()

func main_loop() -> void:
	while true:
		town_commands.start_select()
		await town_commands.exit
		match town_commands.retvar.function:
			"dialog":
				await dialog()
			"battle":
				await Game.start_battle()
			"portrait_edit":
				await Game.start_portrait_edit()

func dialog():
	Dialogic.start_timeline("res://data/dialog/test/battle.dtl")
	await Dialogic.timeline_ended
