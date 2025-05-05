class_name ConversationSubMenu extends Container

var list : UIGenericSelector

func _ready() -> void:
	list = %Actors
	list.info_line = true
	list.cancelable = true
	hide()

func collect_actors() -> void:
	list.erase_commands()
	for actor in Game.get_party(): if actor != Game.get_player():
		var label_faction := Label.new()
		label_faction.text = "パーティ"
		var label_class := Label.new()
		label_class.text = actor.get_class_data().display_name
		var info : Array[Control] = [
			label_faction,
			label_class
		]
		list.add_command(actor.actor_name, "", [actor], func ():, info)
	for actor in Game.game_data.people:
		var label_faction := Label.new()
		label_faction.text = "市民"
		var label_class := Label.new()
		label_class.text = actor.get_class_data().display_name
		var info : Array[Control] = [
			label_faction,
			label_class
		]
		list.add_command(actor.actor_name, "", [actor], func ():, info)

func select_target() -> Actor:
	show()
	list.show()
	collect_actors()
	var ret := list.parse_retval(await list.start_select())
	hide()
	if not ret.canceled and ret.args[0] is Actor:
		return ret.args[0]
	return null
