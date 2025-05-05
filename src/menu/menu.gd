class_name Menu extends CanvasLayer

signal exit()

@export var selector : UIGenericSelector

var status_submenu : PackedScene = load("res://src/menu/status_submenu.tscn")
var inventory_submenu : PackedScene = load("res://src/menu/inventory_submenu.tscn")
var equip_submenu : PackedScene = load("res://src/menu/equip_submenu.tscn")
var ability_submenu : PackedScene = load("res://src/menu/ability_submenu.tscn")
var skill_up_submenu : PackedScene = load("res://src/menu/skill_up_submenu.tscn")
var system_submenu : PackedScene = load("res://src/menu/system_submenu.tscn")

var sort_submenu : SortSubMenu

var submenu_active : bool = false

var last_focus : Control

func _ready() -> void:
	var main : Control = $MenuMain
	last_focus = Game.current_focus
	if not selector: return
	sort_submenu = $SortSubMenu
	sort_submenu.hide()
	var conversation_submenu : ConversationSubMenu = $ConversationSubMenu
	selector.erase_commands()
	selector.add_command("アイテム", "item")
	selector.add_command("装備", "equip")
	selector.add_command("アビリティ", "ability")
	selector.add_command("ステータス", "status")
	selector.add_command("並び替え", "sort")
	selector.add_command("成長", "skill_up")
	selector.add_command("会話", "conversation")
	selector.add_command("システム", "system")
	selector.add_command("デバッグ", "debug")
	selector.add_command("デバッグ(会話)", "debug_conversation")
	selector.add_command("デバッグ(アイテム)", "debug_item")
	while true:
		main.show()
		var ret = UIGenericSelector.parse_retval(await selector.start_select())
		if ret.canceled:
			break
		main.hide()
		match ret.function:
			"item":
				submenu_active = true
				var sub := inventory_submenu.instantiate()
				add_child(sub)
				await sub.exit
			"equip":
				submenu_active = true
				var sub := equip_submenu.instantiate()
				add_child(sub)
				await sub.exit
			"ability":
				submenu_active = true
				var sub := ability_submenu.instantiate()
				add_child(sub)
				await sub.exit
			"skill_up":
				submenu_active = true
				var sub := skill_up_submenu.instantiate()
				add_child(sub)
				await sub.exit
			"status":
				submenu_active = true
				var sub := status_submenu.instantiate() as StatusSubMenu
				add_child(sub)
				await sub.exit
			"sort":
				submenu_active = true
				sort_submenu.start_sort()
				await sort_submenu.sort_exit
			"conversation":
				submenu_active = true
				var target := await conversation_submenu.select_target()
				if target:
					hide()
					Game.generic_conversation(target)
					show()
					break
			"system":
				submenu_active = true
				var sub := system_submenu.instantiate() as SystemSubMenu
				add_child(sub)
				await sub.exit
			"debug":
				Game.start_town()
				break
			"debug_conversation":
				Game.generic_conversation(Game.get_player())
				break
			"debug_item":
				submenu_active = true
				var sub := ItemLoot.instantiate()
				add_child(sub)
				var items : Array[Item]
				for item : ItemData in StaticData.items.values():
					items.append(item.instantiate())
				sub.start(Game.get_party()[0], items)
				await sub.exit
	exit.emit()
	queue_free.call_deferred()
	if last_focus: last_focus.grab_focus()
