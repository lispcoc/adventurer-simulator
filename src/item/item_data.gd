class_name ItemData extends RefCounted

var id : String = "null"
var tname : String = ""
var stackable : bool = false
var wgt : int = 0

var melee_base_times = 2
var melee_base_amount = 2
var melee_base_sides = 4
var melee_base_attack = 0

static func load(list : Dictionary, path : String):
	var database = ItemDataTextDatabase.new()
	database.id_name = "no"
	database.load_from_path(path)
	list.merge(database.get_struct_dictionary(), true)

func instantiate() -> Skill:
	var i = Item.new()
	i.id = id
	return i

class ItemDataTextDatabase extends TextDatabase:
	func _initialize():
		id_name = "no"
		entry_name = "name"
		define_from_struct(ItemData.new)

	func _schema_initialize():
		pass

	func _postprocess_entry(entry: Dictionary):
		pass
