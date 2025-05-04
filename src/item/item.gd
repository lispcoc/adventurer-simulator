class_name Item extends Node

var id = "null"
var uid : String
var stack_size : int = 1

var data : ItemData:
	get: return StaticData.items[id]
	set(_v): pass

var wgt : int:
	get: return data.wgt
	set(_v): pass

func _init() -> void:
	if not uid: uid = UUID.v4()

func display_name():
	return data.display_name

func has_property() -> bool:
	return is_equipment()

func is_equipment() -> bool:
	return data.type in [
		ItemData.Type.Weapon,
		ItemData.Type.Shield,
		ItemData.Type.Torso,
		ItemData.Type.Headwear,
		ItemData.Type.Footwear,
		ItemData.Type.Amulet,
		ItemData.Type.Ring,
	]

static func from_inventory_item(inv_item : InventoryItem) -> Item:
	if inv_item.get_property("item", null):
		return inv_item.get_property("item")
	var item := StaticData.items[inv_item.get_prototype().get_id()].instantiate()
	item.stack_size = inv_item.get_stack_size()
	return item

func to_inventory_item() -> InventoryItem:
	var inv_item = CustomInventoryItem.new(null, id)
	if has_property():
		inv_item.set_property("item", self)
		inv_item.set_property("uid", uid)
	inv_item.set_property("name", display_name())
	inv_item.set_property("image", data.icon)
	inv_item.set_max_stack_size(99)
	inv_item.set_stack_size(1)
	return inv_item

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
	lines.push_back(uid)
	return "\n".join(lines)

func description() ->  String:
	return short_description()

func get_normal_attack() -> Ability:
	return StaticData.ability_from_id(data.normal_attack).instantiate()

class CustomInventoryItem extends InventoryItem:
	func get_texture() -> Texture2D:
		return SpriteManager.load_item_icon(get_property(_KEY_IMAGE), 1)
