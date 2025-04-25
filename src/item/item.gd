class_name Item extends Node

var id = "null"
var uid : String

var data : ItemData:
	get: return StaticData.items[id]
	set(_v): pass

var wgt : int:
	get: return data.wgt
	set(_v): pass

func _init() -> void:
	if not uid: uid = Uuid.v4()

func display_name():
	return data.tname

func melee_roll_damage():
	var amount = data.melee_base_amount
	var sides = data.melee_base_sides
	var attack = data.melee_base_attack
	return DiceRoller.roll_dices(amount, sides) + attack

func get_melee_performance_string() -> String:
	return "%dd%d%+d" % [
		data.melee_base_amount,
		data.melee_base_sides,
		data.melee_base_attack,
		]

func get_defense() -> int:
	return data.armour_base_defense

func is_weapon(): return data.type == ItemData.Type.Weapon
func is_armour():
	return [
		ItemData.Type.Torso,
		ItemData.Type.Shield,
		ItemData.Type.Headwear,
		ItemData.Type.Footwear,
		ItemData.Type.Amulet,
		ItemData.Type.Ring
	].has(data.type)

func short_description() ->  String:
	var lines : PackedStringArray
	lines.push_back(display_name())
	if is_weapon():
		lines.push_back(get_melee_performance_string())
	if is_armour() and get_defense():
		lines.push_back("防御力:%d" % get_defense())
	return "\n".join(lines)
