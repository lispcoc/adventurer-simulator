class_name GameManager extends Control

signal battle_started
signal battle_ended
signal editor_started
signal editor_ended

const MAX_PARTY_MEMBER = 5
const MAX_LINE_MEMBER = 3
const PATH_SAVEDATA = "user://savedata.gdsave"
var game_data : GameData

var scene_town : PackedScene = load("res://src/town/town.tscn")
var scene_dungeon : PackedScene = load("res://src/dungeon/dungeon.tscn")
var scene_battle : PackedScene = load("res://src/battle/battle.tscn")
var scene_portrait_edit : PackedScene = load("res://src/portrait/portrait_editor.tscn")

const FD : PackedScene = preload("res://src/battle/ui/number/floating_damage.tscn")

var current_focus : Control

var scene_stack : Array[GameScene]

#
# Constants
#
enum Target {
	EnemyOne,
	EnemyLine,
	EnemyAll,
	PartyOne,
	PartyLine,
	PartyAll,
	Self,
	All
}

func _ready() -> void:
	StaticData.loaded.connect(on_game_loaded)
	sort_ui()
	get_viewport().gui_focus_changed.connect(watch_focus)
	Dialogic.timeline_started.connect(hide_ui)
	Dialogic.timeline_ended.connect(show_ui)
	battle_started.connect(hide_ui)
	battle_ended.connect(show_ui)
	editor_started.connect(hide_ui)
	editor_ended.connect(show_ui)
	start_town()

func watch_focus(node : Control) -> void:
	current_focus = node

func start_town():
	for m in scene_stack: m.disable()
	var town = scene_town.instantiate()
	scene_stack.append(town)
	get_tree().root.add_child.call_deferred(town)

func start_dungeon() -> void:
	for m in scene_stack: m.disable()
	var dungeon = scene_dungeon.instantiate()
	scene_stack.append(dungeon)
	get_tree().root.add_child.call_deferred(dungeon)

func end_current_scene():
	scene_stack.pop_back()
	scene_stack.back().enable()
	scene_stack.back().start()

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
	reload_ui()

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
	battle_started.emit()
	await Transition.cover(0.5)
	var battle = scene_battle.instantiate() as BattleManager
	get_tree().root.add_child(battle)
	battle.init_test_data()
	await Transition.clear(0.5)
	await battle.start()
	await Transition.clear(0.5)
	battle_ended.emit()
	return true

func start_portrait_edit(ch : Actor) -> bool:
	editor_started.emit()
	var portrait_editor = scene_portrait_edit.instantiate() as PortraitEditor
	portrait_editor.target = ch
	await menu_delay()
	get_tree().root.add_child(portrait_editor)
	await portrait_editor.exit
	await menu_delay()
	editor_ended.emit()
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
	reload_ui()
	return true

func floating_damage(target: Node, val : int, offset : Vector2 = Vector2(0, 0)):
	var damage := FD.instantiate() as FloatingDamage
	damage.text = String.num_uint64(val)
	damage.position = offset
	target.add_child(damage)

func damage_party(dam : Damage):
	for c in get_party():
		c.apply_dagame(dam)
		var p = CharacterPanelUi.get_panel(c)
		floating_damage(p, dam.val)

func show_ui() ->  void:
	CharacterPanelUi.show()

func hide_ui() ->  void:
	CharacterPanelUi.hide()

func reload_ui() -> void:
	CharacterPanelUi.reload()

func update_ui() -> void:
	CharacterPanelUi.update()

func debug_dialog() -> void:
	Dialogic.start_timeline("res://data/dialog/test/debug.dtl")
	await Dialogic.timeline_ended
