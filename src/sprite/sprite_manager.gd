class_name _SpriteManager extends Node

var battle_actors : Dictionary[String, Texture2D]

var controller_buttons : Dictionary[String, Texture2D] = {
	"ui_accept" : preload("res://assets/gui/controller/accept.png"),
	"ui_cancel" : preload("res://assets/gui/controller/cancel.png"),
	"sub" : preload("res://assets/gui/controller/sub.png"),
	"description" : preload("res://assets/gui/controller/description.png"),
	"direction" : preload("res://assets/gui/controller/direction.png"),
	"direction_lr" : preload("res://assets/gui/controller/direction_lr.png"),
}

var item_icons : Dictionary[String, String] = {
}

func _ready() -> void:
	#load_battle_actors()
	pass

func load_battle_actor(id : String) -> Texture2D:
	if not battle_actors.has(id):
		var dir = DirAccess.open(ProjectSettings.globalize_path("res://assets/battle_actors/"))
		print("load_battle_actors: %s" % dir.get_current_dir())
		for file in dir.get_files():
			var _id := file.split(".")[0]
			if file.ends_with(".png") and id == _id:
				var path := dir.get_current_dir().path_join(file)
				print("load_battle_actors: %s" % path)
				var image = Image.new()
				image.load(path)
				var texture = ImageTexture.create_from_image(image)
				battle_actors[id] = texture
	if battle_actors.has(id): return battle_actors[id]
	return null

func load_controller_button(id):
	if controller_buttons.has(id): return controller_buttons[id]
	return null

func get_item_icon_path(id):
	var dir := DirAccess.open(ProjectSettings.globalize_path("res://assets/items/"))
	for subdir_name in dir.get_directories():
		var subdir := DirAccess.open(ProjectSettings.globalize_path("res://assets/items/" + subdir_name))
		for file in subdir.get_files():
			var _id := file.split(".")[0]
			if file.ends_with(".png") and id == _id:
				return subdir.get_current_dir().path_join(file)
	return null
