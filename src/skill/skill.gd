class_name Skill extends RefCounted

var id : String
var display_name : String
var phy_consume : int = 0
var tec_consume : int = 0
var mnd_consume : int = 0

static func load(list : Dictionary[String, Skill], path : String):
	var database = SkillTextDatabase.new()
	database.id_name = "no"
	database.load_from_path(path)
	list.merge(database.get_struct_dictionary(), true)

func next_phy(next_level : int) -> int:
	return int(phy_consume * pow(1.5, next_level - 1))

func next_tec(next_level : int) -> int:
	return int(tec_consume * pow(1.5, next_level - 1))

func next_mnd(next_level : int) -> int:
	return int(mnd_consume * pow(1.5, next_level - 1))

class SkillTextDatabase extends TextDatabase:
	func _initialize():
		id_name = "no"
		entry_name = "id"
		define_from_struct(Skill.new)

	func _preprocess_entry(_entry): pass

	func _postprocess_entry(_entry: Dictionary): pass
