class_name BattleActorPlayer extends BattleActor

const panel_path = "res://src/common/character_panel/character_panel.tscn"

var panel_scene : PackedScene
var panel : CharacterPanel

func _init() -> void:
	panel_scene = load(panel_path)
	panel = panel_scene.instantiate()
	button = panel
	super._init()

func _ready():
	custom_minimum_size = panel.custom_minimum_size
	button.size = custom_minimum_size
	panel.update()
	super._ready()

func on_set_hp(_val : int):
	panel.update()

func on_set_mp(_val : int):
	panel.update()

func on_status_update() -> void:
	panel.update()

func on_set_actor():
	panel.actor = actor
	panel.update()

func on_main_entered():
	panel.highlight()

func on_main_exit():
	panel.highlight(false)

func is_ally() -> bool:
	return true

func is_player() -> bool:
	return Game.get_player() == actor

func pop_cursor() -> void: panel.pop_cursor()
func remove_cursor() -> void: panel.remove_cursor()
