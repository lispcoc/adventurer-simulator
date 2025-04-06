class_name Actor

var eqip : Equip = Equip.new()
var inventory : Array[Item] = []

var class_id : String = "warrior"
var level : int = 30:
	set(v):
		level = v
		recalc_status()

var init : bool = false
var hp_max : int = 10
var mp_max : int = 10
var hp : int = 10
var mp : int = 10
var strength : int = 10
var constitution : int = 10
var dexterity : int = 10
var magic : int = 10
var mind : int = 10

func _init() -> void:
	if !init:
		init = true
		initialize_actor()

func initialize_actor():
	recalc_status()
	hp = hp_max
	mp = mp_max

func recalc_status():
	var cls = get_class_data()
	hp_max = cls.base_hp + max(0, (cls.grow_hp + constitution / 2.0 + strength / 4.0)) * level
	mp_max = cls.base_mp + max(0, (cls.grow_mp + magic / 2.0 + mind / 4.0)) * level

func get_class_data() -> Class:
	return StaticData.classes[class_id]

class Equip:
	var head : Item
	var body : Item
	var foot : Item
	var ring : Item
	var backpack : Item
