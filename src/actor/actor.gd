class_name Actor extends Node

signal on_dead()

enum Sex {
	Male,
	Female
}

var actor_name : String = "名無し"
var sex : Sex = Sex.Female

var portrait : String = ""

var skills : Array[Skill]
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
var hp : int = 10:
	set = set_hp
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
		test()
		pick_random_name()

func test():
	var s = StaticData.skill_from_id("魔神斬り").instantiate()
	skills.append(s)
	skills.append(StaticData.skill_from_id("軽傷治癒").instantiate())

func pick_random_name():
	actor_name = StaticData.names.get_female_name()

func initialize_actor():
	recalc_status()
	hp = hp_max
	mp = mp_max

func recalc_status():
	var cls = get_class_data()
	hp_max = cls.base_hp + max(0, (cls.grow_hp + constitution / 2.0 + strength / 4.0)) * level
	mp_max = cls.base_mp + max(0, (cls.grow_mp + magic / 2.0 + mind / 4.0)) * level
	hp = min(hp_max, hp)
	mp = min(mp_max, mp)

func get_class_data() -> Class:
	return StaticData.classes[class_id]

func get_weapon() -> Item:
	if eqip.weapon:
		return eqip.weapon
	else:
		return Item.new()

func get_atk() -> int:
	return int(strength / 2.0)

# =($D$3+20) * MAX(1, 8 + $B$3 - B9) / 3000
func get_melee_times(sk : Skill = null, weapon : Item = null) -> int:
	if sk:
		if sk.data.melee_time_override: return sk.data.melee_time_override
	if weapon == null: weapon = get_weapon()
	var grow_rate = (dexterity + 20) * max(1, 8 + strength - get_weapon().wgt) / 3000.0 
	return get_weapon().data.melee_base_times + grow_rate * level

func roll_melee_damage(sk : Skill = null) -> Damage:
	var val = get_weapon().melee_roll_damage() + get_atk()
	if sk:
		val *= sk.data.melee_damage_mul
	return Damage.new(val, Attribute.Type.Bash)

func get_hit() -> int:
	return int(dexterity / 2.0)

func get_dodge() -> int:
	return int(dexterity / 2.0)

func apply_dagame(dam : Damage) -> int:
	hp -= dam.val
	return dam.val

func set_hp(v : int):
	hp = max(v, 0)

class Equip:
	var weapon : Item
	var head : Item
	var body : Item
	var foot : Item
	var ring : Item
	var backpack : Item
