class_name ConversationSubMenu extends Container

var list : UIGenericSelector

func _ready() -> void:
	list = %Actors
	list.info_line = true
	list.cancelable = true
	for actor in Game.get_party(): if actor != Game.get_player():
		var label_class := Label.new()
		label_class.text = actor.get_class_data().display_name
		var info : Array[Control] = [
			label_class
		]
		list.columns = info.size() + 1
		list.add_command(actor.actor_name, "", [actor], func ():, info)
	hide()

func select_target() -> Actor:
	show()
	list.show()
	var ret := list.parse_retval(await list.start_select())
	hide()
	if not ret.canceled and ret.args[0] is Actor:
		return ret.args[0]
	return null
