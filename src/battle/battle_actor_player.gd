class_name BattleActorPlayer extends BattleActor

const panel_path = "res://src/common/character_panel/character_panel.tscn"

var panel_scene : PackedScene
var panel : CharacterPanel

func _init() -> void:
	panel_scene = load(panel_path)
	panel = panel_scene.instantiate()
	add_child(panel)
	super._init()

func _ready():
	super._ready()
	custom_minimum_size = panel.custom_minimum_size
	button.size = custom_minimum_size
	update_panel()

func update_panel():
	panel.set_hp(hp, hp_max)

func on_set_hp(val : int):
	print(val, hp_max)
	update_panel()

func is_player() -> bool:
	return true
