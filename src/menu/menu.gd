class_name Menu extends CanvasLayer

signal exit()

@export var selector : UIGenericSelector

func _ready() -> void:
	if not selector: return
	selector.erase_commands()
	selector.add_command("アイテム", "item")
	selector.add_command("装備", "equip")
	selector.add_command("ステータス", "status")
	selector.add_command("並び替え", "sort")
	selector.add_command("会話", "talk")
	selector.add_command("デバッグ", "debug")
	while true:
		var ret = selector.parse_retval(await selector.start_select())
		if ret.canceled:
			break
		match ret.function:
			"debug":
				Game.start_town()
				break
	queue_free.call_deferred()
	exit.emit()
