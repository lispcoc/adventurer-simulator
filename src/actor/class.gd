class_name Class

var display_name : String
var base_hp : int = 10
var grow_hp : int = 2

var base_mp : int = 0
var grow_mp : int = 0

var skills : PackedStringArray

const DEFAULT_CLASS : String = "warrior"

static func load(list : Dictionary[String, Class], path : String):
	var database = ClassTextDatabase.new()
	database.id_name = "no"
	database.load_from_path(path)
	list.merge(database.get_struct_dictionary(), true)

func from_json(json : Dictionary):
	base_hp = json["base_hp"]
	grow_hp = json["grow_hp"]
	base_mp = json["base_mp"]
	grow_mp = json["grow_mp"]


class ClassTextDatabase extends TextDatabase:
	func _initialize():
		id_name = "no"
		entry_name = "id"
		define_from_struct(Class.new)

	func _preprocess_entry(entry):
		if entry.has("skills"):
			var ret : PackedStringArray
			for s in entry.skills: ret.append(s)
			entry.skills = ret

	func _postprocess_entry(_entry: Dictionary): pass
