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

var item_icons : Dictionary[String, Texture2D]
var item_icons_with_bg : Dictionary[String, SubViewport]


func _ready() -> void: pass

func load_battle_actor(id : String) -> Texture2D:
	if not battle_actors.has(id):
		for path in get_files_recursive("res://assets/battle_actors/", ".png"):
			if path.ends_with(id + ".png"):
				battle_actors[id] = load(path)
				return battle_actors[id]
	if battle_actors.has(id): return battle_actors[id]
	return null

func load_controller_button(id):
	if controller_buttons.has(id): return controller_buttons[id]
	return null

func load_item_icon(id, rarelity : int = 0) -> Texture2D:
	if not item_icons.has(id):
		for path in get_files_recursive("res://assets/items/", ".png"):
			if path.ends_with(id + ".png"):
				item_icons[id] = load(path)
				break
	if not item_icons.has(id): return null
	if rarelity == 0: return item_icons[id]

	if not item_icons_with_bg.has(id):
		item_icons_with_bg[id] = SubViewport.new()
		item_icons_with_bg[id].size = item_icons[id].get_size() + Vector2(4, 4)
		var sp := Sprite2D.new()
		sp.texture = item_icons[id]
		sp.centered = false
		sp.position = Vector2(2, 2)
		var bg := ColorRect.new()
		bg.color = Color("#ee82ee")
		bg.size = item_icons_with_bg[id].size
		add_child(item_icons_with_bg[id])
		item_icons_with_bg[id].add_child(bg)
		item_icons_with_bg[id].add_child(sp)
	return item_icons_with_bg[id].get_texture()

func get_files_recursive(path : String, ext : String) -> PackedStringArray:
	var ret : PackedStringArray
	var dir := DirAccess.open(ProjectSettings.globalize_path(path))
	for subdir_name in dir.get_directories():
		var subdir_path := dir.get_current_dir().path_join(subdir_name)
		ret.append_array(get_files_recursive(subdir_path, ext))
	for file in dir.get_files():
		var _id := file.split(".")[0]
		if file.ends_with(ext):
			ret.append(dir.get_current_dir().path_join(file))
	return ret
