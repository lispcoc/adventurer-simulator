@tool
class_name Portrait extends DialogicPortrait
#@export_tool_button("btn", "")

@export var timed_update : bool = false

@export var skin_color : int = 0:
	set(v):
		skin_color = v
		_on_update()

var data : Dictionary = {
	"hat_back": 1,
	"hair_back": 1,
	"body": 1,
	"face": 1,
	"eye": 1,
	"eyebrow": 1,
	"eyelid": 1,
	"mouth": 1,
	"cheek": 1,
	"glasses": 1,
	"clothing": 1,
	"hair_front": 1,
	"hat": 1,
}:
	set(v):
		for k in v.keys().filter(func(k): return data[k] != v[k]):
			set_type(k, v[k])

var parts_color : Dictionary = {
	"hat_back": 0,
	"hair_back": 0,
	"body": 0,
	"face": 0,
	"eye": 0,
	"eyebrow": 0,
	"eyelid": 0,
	"mouth": 0,
	"cheek": 0,
	"glasses": 0,
	"clothing": 0,
	"hair_front": 0,
	"hat": 0,
}:
	set(v):
		for k in v.keys().filter(func(k): return parts_color[k] != v[k]):
			set_color(k, v[k])

var parts_offset_y : Dictionary = {
	"hat_back": 0,
	"hair_back": 0,
	"body": 0,
	"face": 0,
	"eye": 0,
	"eyebrow": 0,
	"eyelid": 0,
	"mouth": 0,
	"cheek": 0,
	"glasses": 0,
	"clothing": 0,
	"hair_front": 0,
	"hat": 0,
}:
	set(v):
		parts_offset_y = v
		_on_update()

var color_interlock_set : Array[String] = [
	"hair_front:hair_back",
	"hat:hat_back",
]

var type_interlock_set : Array[String] = [
	"hat:hat_back",
]

var name_dict : Dictionary = {
	"hat_back": "後帽子",
	"hair_back": "後髪",
	"body": "体型",
	"face": "輪郭",
	"eye": "目",
	"eyebrow": "眉毛",
	"eyelid": "瞼",
	"mouth": "口",
	"cheek": "頬",
	"glasses": "眼鏡",
	"clothing": "服",
	"hair_front": "前髪",
	"hat": "帽子"
}

@export var default_palette : Texture2D

@export var flip_h : bool = false:
	set(v):
		flip_h = v
		for p in get_parts(): p.flip_h = v
@export var flip_v : bool = false:
	set(v):
		flip_v = v
		for p in get_parts(): p.flip_v = v

var skin_color_list : PackedColorArray = [
	Color("#FFFFFF"),
	Color("#ffdbcc"),
	Color("#99593d"),
	Color("#6e9999"),
]:
	set(v):
		skin_color_list = v
		_on_update()

var num_parts : Dictionary

func _ready() -> void:
	reflesh()

func _process(delta: float) -> void:
	if timed_update:
		print(delta)
		reflesh()

func _update_portrait(passed_character:DialogicCharacter, passed_portrait:String) -> void:
	print("_update_portrait")
	print(passed_character)
	print(passed_portrait)

func reflesh():
	for c in get_children():
		c = c as AnimatedSprite2D
		if data.keys().find(c.name) < 0:
			data[c.name] = 0
		num_parts[c.name] = c.sprite_frames.get_frame_count(c.animation)
	for k in data.keys():
		var s = find_child(k) as AnimatedSprite2D
		if s:
			s.frame = data[k]
	for k in parts_color.keys():
		var part = find_child(k) as PortraitPart
		if part:
			if part.validate_color_index(parts_color[k]):
				part.color_index = parts_color[k]
			else:
				parts_color[k] = part.color_index
	for k in parts_offset_y.keys():
		var s = find_child(k) as AnimatedSprite2D
		if s:
			s.position.y = parts_offset_y[k]
	reflesh_skin()

func _on_update():
	reflesh()

func reflesh_skin():
	var skin_names = [
		"body",
		"face",
		"cheek",
		"eyelid",
		"mouth",
	]
	for k in skin_names:
		var c = find_child(k) as AnimatedSprite2D
		if c: c.modulate = skin_color_list[skin_color]

func set_type(key : String, val : int):
	data[key] = val
	# interlock
	for str in type_interlock_set:
		var a = str.split(":")
		if a.has(key):
			for key_2 in a:
				data[key_2] = val
			break
	_on_update()

func set_color(key : String, val : int):
	parts_color[key] = val
	# interlock
	for str in color_interlock_set:
		var a = str.split(":")
		if a.has(key):
			for key_2 in a:
				parts_color[key_2] = val
			break
	_on_update()

func get_color(part : String) -> int:
	if parts_color[part] : return parts_color[part]
	return 0

func get_color_count(key : String) -> int:
	var part = find_child(key) as PortraitPart
	if part: return part.get_color_count()
	return 0

func get_keys() -> Array[String]:
	var keys : Array[String]
	get_children().map(func (c): keys.append(c.name))
	return keys

func get_color_keys() -> Array[String]:
	var keys : Array[String]
	for c in get_children():
		var part = c as PortraitPart
		if part and part.get_color_count(): keys.append(c.name)
	return keys
	
func get_key_name(key : String) -> String:
	return name_dict[key]

func get_parts() -> Array[AnimatedSprite2D]:
	var _parts : Array[AnimatedSprite2D]
	for c in get_children():
		if c as AnimatedSprite2D: _parts.append(c)
	return _parts

func _to_string() -> String:
	var parameters : Dictionary = {
		"skin_color" : skin_color,
		"parts" : data,
		"parts_color" : parts_color,
		"parts_offset_y" : parts_offset_y,
	}
	return var_to_str(parameters)

func from_string(str : String) -> void:
	var parameters : Dictionary = str_to_var(str)
	skin_color = parameters.skin_color
	data = parameters.parts
	parts_color = parameters.parts_color
	parts_offset_y = parameters.parts_offset_y
	reflesh()
