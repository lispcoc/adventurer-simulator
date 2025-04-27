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
var magic : int = 10
var mind : int = 10

func _init() -> void:
	if !init:
		init = true
		initialize_actor()
		#test()
		pick_random_name()

func _on_status_update() -> void:
	if Game.is_inside_tree(): Game.get_tree().call_group("status_ui", "update")

func load_from_monster_data(data : MonsterData):
	class_id = data.class_id
	initialize_actor()
	actor_name = data.display_name
	for sid in data.skills:
		skills.append(StaticData.skill_from_id(sid).instantiate())

func test():
	var s = StaticData.skill_from_id("魔神斬り").instantiate()
	skills.append(s)
	skills.append(StaticData.skill_from_id("軽傷治癒").instantiate())

func get_skills() -> Array[Skill]:
	var class_skills : Array[Skill]
	for sid in get_class_data().skills:
		class_skills.append(StaticData.skill_from_id(sid).instantiate())
	return skills + class_skills

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
	_on_status_update()

func add_item(item : Item) -> void:
	inventory.append(item)

func remove_item(item : Item) -> void:
	inventory.erase(item)

func spawn_inventory(template : CtrlInventory, filter : Callable = func (item : Item): return true) -> CtrlInventory:
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
