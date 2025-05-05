class_name FactionType extends RefCounted

var display_name : String
var world_global : bool = false

static func load(list : Dictionary[String, FactionType], path : String):
	var database = FactionTextDatabase.new()
	database.id_name = "no"
	database.load_from_path(path)
	list.merge(database.get_struct_dictionary(), true)


class FactionTextDatabase extends TextDatabase:
	func _initialize():
		id_name = "no"
		entry_name = "id"
		define_from_struct(FactionType.new)

	func _preprocess_entry(_entry: Dictionary): pass

	func _postprocess_entry(_entry: Dictionary): pass
