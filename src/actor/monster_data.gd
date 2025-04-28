class_name MonsterData extends RefCounted

var display_name : String
var class_id : String
var skills : PackedStringArray

static func load(list : Dictionary[String, MonsterData], path : String):
	var database = MonsterTextDatabase.new()
	database.id_name = "no"
	database.load_from_path(path)
	list.merge(database.get_struct_dictionary(), true)


class MonsterTextDatabase extends TextDatabase:
	func _initialize():
		id_name = "no"
		entry_name = "id"
		define_from_struct(MonsterData.new)

	func _preprocess_entry(entry):
		if entry.has("skills"):
			var ret : PackedStringArray
			for s in entry.skills: ret.append(s)
			entry.skills = ret

	func _postprocess_entry(_entry: Dictionary): pass
