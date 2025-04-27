class_name ItemData extends RefCounted

enum Type {
	Weapon,
	Shield,
	Torso,
	Headwear,
	Footwear,
	Amulet,
	Ring,
	Consumables,
}

var id : String = "null"
var display_name : String = ""
var stackable : bool = false
var wgt : int = 0
var type : Type = Type.Consumables

var melee_base_times = 2
var melee_base_amount = 2
var melee_base_sides = 4
var melee_base_attack = 0

var armour_base_defense = 0

static func load(list : Dictionary, path : String):
	var database = ItemDataTextDatabase.new()
	database.id_name = "no"
	database.load_from_path(path)
	list.merge(database.get_struct_dictionary(), true)

func instantiate() -> Item:
	var i = Item.new()
	i.id = id
	return i

class ItemDataTextDatabase extends TextDatabase:
	func _initialize():
		id_name = "no"
		entry_name = "id"
		define_from_struct(ItemData.new)

	func _schema_initialize():
		override_property_type("type", TYPE_STRING)

	func _postprocess_entry(entry: Dictionary):
		#entry.id = entry.tname
		if "type" in entry:
			for i in ItemData.Type.keys().size():
				if ItemData.Type.keys()[i] == entry.type:
					entry.type = i
					break
