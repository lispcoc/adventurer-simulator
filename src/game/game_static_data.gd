class_name GameStaticData extends Node

signal loaded

var classes : Dictionary = {}

func _ready() -> void:
	print("GameStaticData._ready")
	load_classes()
	emit_signal("loaded")

func load_classes():
	var file_path = "res://data/json/classes.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var json = JSON.parse_string(text)
		for e in json:
			classes[e.id] = Class.new()
			classes[e.id].from_json(e)
		file.close()
	else:
		print("failed to load class.")
	print(classes)
