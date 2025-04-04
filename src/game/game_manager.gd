class_name GameManager extends Control

const PATH_SAVEDATA = "user://savedata.gdsave"
var game_data : GameData

func _ready() -> void:
	make_dummy_savedata()

	if FileAccess.file_exists(PATH_SAVEDATA) == false:
		print("セーブデータが存在しません: %s"%PATH_SAVEDATA)
		return

	var f = FileAccess.open(PATH_SAVEDATA, FileAccess.READ)
	print(f.get_as_text())
	game_data = str_to_var(f.get_as_text())

func make_dummy_savedata() -> void:
	game_data = GameData.new()
	game_data.test_var = 2
	game_data.add_people(Character.new())
	game_data.add_people(Character.new())
	game_data.add_people(Character.new())
	var f = FileAccess.open(PATH_SAVEDATA, FileAccess.WRITE)
	f.store_string(var_to_str(game_data))
	f.close()
