class_name GameManager extends Control

const PATH_SAVEDATA = "user://savedata.gdsave"
var game_data : GameData

var scene_battle : PackedScene = load("res://src/battle/battle.tscn")

func _ready() -> void:
	StaticData.loaded.connect(on_game_loaded)
	sort_ui()

func sort_ui() -> void:
	get_parent().move_child.call_deferred(DialogUi, get_parent().get_child_count() - 1)
	get_parent().move_child.call_deferred(Transition, get_parent().get_child_count() - 1)

func on_game_loaded():
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
	game_data.add_people(Actor.new())
	game_data.add_people(Actor.new())
	game_data.add_people(Actor.new())
	var f = FileAccess.open(PATH_SAVEDATA, FileAccess.WRITE)
	var s = var_to_str(game_data)
	f.store_string(s)
	f.close()

func start_battle() -> bool:
	await Transition.cover(0.5)
	var battle = scene_battle.instantiate() as BattleManager
	get_tree().root.add_child(battle)
	battle.init_test_data()
	await Transition.clear(0.5)
	await battle.start()
	await Transition.clear(0.5)
	return true
