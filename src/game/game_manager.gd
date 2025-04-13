class_name GameManager extends Control

const MAX_PARTY_MEMBER = 5
const MAX_LINE_MEMBER = 3
const PATH_SAVEDATA = "user://savedata.gdsave"
var game_data : GameData

var scene_battle : PackedScene = load("res://src/battle/battle.tscn")
var scene_portrait_edit : PackedScene = load("res://src/portrait/portrait_editor.tscn")

var current_focus : Control

func _ready() -> void:
	StaticData.loaded.connect(on_game_loaded)
	sort_ui()
	get_viewport().gui_focus_changed.connect(watch_focus)

func watch_focus(node : Control) -> void:
	current_focus = node

func sort_ui() -> void:
	get_parent().move_child.call_deferred(DialogUi, get_parent().get_child_count() - 1)
	get_parent().move_child.call_deferred(Transition, get_parent().get_child_count() - 1)

func on_game_loaded() -> void:
	load_data()

func load_data() -> void:
	make_dummy_data()
	if FileAccess.file_exists(PATH_SAVEDATA) == false:
		print("セーブデータが存在しません: %s"%PATH_SAVEDATA)
		return
	var f = FileAccess.open(PATH_SAVEDATA, FileAccess.READ)
	print(f.get_as_text())
	game_data = str_to_var(f.get_as_text())
	reflesh_ui()

func save_data() -> bool:
	var f = FileAccess.open(PATH_SAVEDATA, FileAccess.WRITE)
	var s = var_to_str(game_data)
	f.store_string(s)
	f.close()
	return true

func make_dummy_data() -> void:
	game_data = GameData.new()
	game_data.test_var = 2
	game_data.add_party(Actor.new())
	game_data.add_people(Actor.new())
	game_data.add_people(Actor.new())
	game_data.add_people(Actor.new())

func start_battle() -> bool:
	await Transition.cover(0.5)
	var battle = scene_battle.instantiate() as BattleManager
	get_tree().root.add_child(battle)
	battle.init_test_data()
	await Transition.clear(0.5)
	await battle.start()
	await Transition.clear(0.5)
	return true

func start_portrait_edit(ch : Actor) -> bool:
	var portrait_editor = scene_portrait_edit.instantiate() as PortraitEditor
	portrait_editor.target = ch
	await menu_delay()
	get_tree().root.add_child(portrait_editor)
	await portrait_editor.exit
	await menu_delay()
	return true

func menu_delay() -> void:
	await get_tree().create_timer(0.5).timeout

func get_party(front : bool = true, back : bool = true) -> Array[Actor]:
	var party : Array[Actor] = []
	if front: party.append_array(game_data.party_front)
	if back: party.append_array(game_data.party_back)
	return party

func add_party(member : Actor) ->  bool:
	if not get_party().size() < MAX_PARTY_MEMBER:
		return false
	if game_data.party_front.size() < MAX_LINE_MEMBER:
		game_data.party_front.append(member)
	else:
		game_data.party_back.append(member)
	reflesh_ui()
	return true

func show_ui() ->  void:
	CharacterPanelUi.show()

func hide_ui() ->  void:
	CharacterPanelUi.hide()

func reflesh_ui() -> void:
	CharacterPanelUi.reflesh()

func debug_dialog() -> void:
	Dialogic.start_timeline("res://data/dialog/test/debug.dtl")
	await Dialogic.timeline_ended
