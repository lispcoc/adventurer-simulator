@tool
class_name NameList extends RefCounted

var female_name : Array[String]

func load(path : String):
	var database = TextDatabase.new()
	database.load_from_path(path)
	var dict = database.get_dictionary()
	for n in dict["female_name"]["list"]:
		female_name.append(n as String)

func get_female_names() -> Array[String]:
	return female_name

func get_female_name() -> String:
	return female_name[randi() % female_name.size()]
