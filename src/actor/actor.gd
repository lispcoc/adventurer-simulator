class_name Actor extends Node

@warning_ignore("unused_signal")
signal on_dead()

enum Sex {
	Male,
	Female
}

var actor_name : String = "名無し"
var sex : Sex = Sex.Female

var portrait : String = ""

var abilities : Array[Ability]
var equip : Equip = Equip.new()
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
var intelligence : int = 10
var mind : int = 10

class Status extends RefCounted:
	enum Id{
		STR = 0,
		CON,
		DEX,
		INT,
		MND
	}
	const _list : PackedStringArray = [
		"strength",
		"constitution",
		"dexterity",
		"intelligence",
		"mind",
	]
	const _name_list : PackedStringArray = [
		"筋力",
		"耐久",
		"器用",
		"知力",
		"精神",
	]
	static func from_id(id : Id) -> String: return _list[id]
	static func keys() -> PackedStringArray: return _list
	static func string(id : Id) -> String: return _name_list[id]

func _init() -> void:
	if !init:
		init = true
		initialize_actor()
		pick_random_name()

func _on_status_update() -> void:
	if Game.is_inside_tree(): Game.get_tree().call_group("status_ui", "update")

func load_from_monster_data(data : MonsterData):
	class_id = data.class_id
	initialize_actor()
	actor_name = data.display_name
	for sid in data.abilities:
		abilities.append(StaticData.ability_from_id(sid).instantiate())

func get_abilities() -> Array[Ability]:
	var class_abilities : Array[Ability]
	for sid in get_class_data().abilities:
		class_abilities.append(StaticData.ability_from_id(sid).instantiate())
	return abilities + class_abilities

func pick_random_name():
	actor_name = StaticData.names.get_female_name()

func initialize_actor():
	recalc_status()
	hp = hp_max
	mp = mp_max

func recalc_status():
	var cls = get_class_data()
	hp_max = cls.base_hp + max(0, (cls.grow_hp + get_status(Status.Id.CON) / 2.0 + get_status(Status.Id.STR) / 4.0)) * level
	mp_max = cls.base_mp + max(0, (cls.grow_mp + get_status(Status.Id.INT) / 2.0 + get_status(Status.Id.MND) / 4.0)) * level
	hp = min(hp_max, hp)
	mp = min(mp_max, mp)

func get_class_data() -> Class:
	if not StaticData.classes.has(class_id): class_id = Class.DEFAULT_CLASS
	return StaticData.classes[class_id]

func get_item_from_uid(uid : String) -> Item:
	for item in inventory: if item.uid == uid: return item
	return null

func get_weapon() -> Item:
	var item = get_item_from_uid(equip.weapon_uid)
	if item: return item
	else: return Item.new()

func set_equip(item : Item) -> void:
	equip.set_item(item)

func set_weapon(item : Item) -> void:
	equip.weapon_uid = item.uid

func get_torso() -> Item:
	var item = get_item_from_uid(equip.torso_uid)
	if item: return item
	else: return Item.new()

func get_headwear() -> Item:
	var item = get_item_from_uid(equip.headwear_uid)
	if item: return item
	else: return Item.new()

func get_footwear() -> Item:
	var item = get_item_from_uid(equip.footwear_uid)
	if item: return item
	else: return Item.new()

func get_status(id : Status.Id) -> int:
	return get(Status.from_id(id))

func get_bonus(id : Status.Id) -> int:
	var val : int = get(Status.from_id(id))
	return int(val / 2.0)

func get_atk() -> int:
	return get_bonus(Status.Id.STR)

# =($D$3+20) * MAX(1, 8 + $B$3 - B9) / 3000
func get_melee_times(sk : Ability = null, weapon : Item = null) -> int:
	if sk:
		if sk.data.melee_time_override: return sk.data.melee_time_override
	if weapon == null: weapon = get_weapon()
	var grow_rate = (dexterity + 20) * max(1, 8 + strength - get_weapon().wgt) / 3000.0 
	return get_weapon().data.melee_base_times + grow_rate * level

func roll_melee_damage(sk : Ability = null) -> Damage:
	var val = get_weapon().melee_roll_damage() + get_atk()
	if sk:
		val *= sk.data.melee_damage_mul
	return Damage.new(val, Attribute.Type.Bash)

func get_hit() -> int:
	return get_bonus(Status.Id.DEX)

func get_dodge() -> int:
	return get_bonus(Status.Id.DEX)

func apply_dagame(dam : Damage) -> int:
	hp -= dam.val
	return dam.val

func set_hp(v : int):
	hp = min(hp_max, max(v, 0))
	_on_status_update()

func heal_hp(v : int):
	hp += v
	for panel in Game.get_panels(self): panel.pop_number(v, Color("green"))

func add_item(item : Item) -> void:
	inventory.append(item)

func remove_item(item : Item) -> void:
	inventory.erase(item)

func spawn_inventory(template : CtrlInventory, filter : Callable = func (_item : Item): return true) -> CtrlInventory:
	var ctrl_inventory : CtrlInventory = template.duplicate()
	var _inventory = Inventory.new()
	ctrl_inventory.set_meta("owner", self)
	ctrl_inventory.inventory = _inventory
	for item in self.inventory: if filter.call(item):
		var inv_item = InventoryItem.new()
		inv_item.set_property("item", item)
		inv_item.set_property("owner", self)
		if self.get_weapon() == item:
			inv_item.set_property("name", "(E)" + item.display_name())
		else:
			inv_item.set_property("name", item.display_name())
		_inventory.add_item(inv_item)
	_inventory.item_added.connect(
		func (inv_item : InventoryItem):
			var item : Item = inv_item.get_property("item")
			self.add_item(item)
	)
	_inventory.item_removed.connect(
		func (inv_item : InventoryItem):
			var item : Item = inv_item.get_property("item")
			self.remove_item(item)
	)
	return ctrl_inventory
