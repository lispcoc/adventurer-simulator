class_name Menu extends CanvasLayer

signal exit()

@export var selector : UIGenericSelector

var sort_submenu : SortSubMenu

var submenu_active : bool = false

var last_focus : Control

func _ready() -> void:
	last_focus = Game.current_focus
	if not selector: return
	sort_submenu = $SortSubMenu
	sort_submenu.hide()
	selector.erase_commands()
	selector.add_command("アイテム", "item")
	selector.add_command("装備", "equip")
	selector.add_command("ステータス", "status")
	selector.add_command("並び替え", "sort")
	selector.add_command("会話", "talk")
	selector.add_command("デバッグ", "debug")
	while true:
		print("aaaaa")
		var ret = selector.parse_retval(await selector.start_select())
		if ret.canceled:
			break
		match ret.function:
			"sort":
				submenu_active = true
				sort_submenu.start_sort()
				await sort_submenu.sort_exit
			"debug":
				Game.start_town()
				break
	exit.emit()
	queue_free.call_deferred()
	if last_focus: last_focus.grab_focus()
