class_name Class

var base_hp : int = 10
var grow_hp : int = 2

var base_mp : int = 0
var grow_mp : int = 0

func from_json(json : Dictionary):
	base_hp = json["base_hp"]
	grow_hp = json["grow_hp"]
	base_mp = json["base_mp"]
	grow_mp = json["grow_mp"]
