class_name Actor extends Node

@warning_ignore("unused_signal")
signal on_dead()

enum Sex {
	Male,
	Female
}

#
# Meta
#
var init : bool = false
var actor_name : String = "名無し"
var sex : Sex = Sex.Female
var portrait : String = ""
var class_id : String = "warrior"

#
# 付帯データ
#
var abilities : Array[Ability]
var equip : Equip = Equip.new()
var inventory : Array[Item]

#
# 経験値
#
var experience : int = 0
var phy_experience : int = 0
var tec_experience : int = 0
var mnd_experience : int = 0

#
# ステータス
#
var level : int = 30:
	set(v):
		level = v
		recalc_status()

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

#
# スキル
#
var skills : Dictionary[String, int]

func _init() -> void:
	if !init:
		init = true
		initialize_actor()
		pick_random_name()

func _on_status_update() -> void:
	if Game.is_inside_tree(): Game.get_tree().call_group("status_ui", "update")

#
# Meta
#
func deep_clone() -> Actor: return str_to_var(var_to_str(self))

func get_usable_bonus_point() -> int:
	return 200

func get_used_bonus_point() -> int:
	var val := 0
	# 6-12 10Pt, 13-16 20pt 17-20 40pt
	for id in Actor.Status.Id.values():
		val += max(get_status(id) - 6, 0) * 10
		val += max(get_status(id) - 12, 0) * 10
		val += max(get_status(id) - 16, 0) * 20
	return val

func get_actions() -> Array[Ability]:
	var ret : Array[Ability] = [get_weapon().get_normal_attack()]
	return ret + get_abilities()

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

func set_status(id : Status.Id, value : int):
	set(Status.from_id(id), value)

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

#
# スキル
#
func get_skill_level(skill : Skill) -> int:
	if not skills.has(skill.id): return 0
	return skills[skill.id]

func mod_skill_level(skill : Skill, level_ : int) -> void:
	set_skill_level(skill, get_skill_level(skill) + level_)

func set_skill_level(skill : Skill, level_ : int) -> void:
	skills[skill.id] = level_


#
# 経験値
#
func get_phy_exp() -> int: return phy_experience
func get_tec_exp() -> int: return tec_experience
func get_mnd_exp() -> int: return mnd_experience

func gain_phy_exp(val : int) -> void: phy_experience += val
func gain_tec_exp(val : int) -> void: tec_experience += val
func gain_mnd_exp(val : int) -> void: mnd_experience += val

func has_exp_to_skill(skill : Skill) -> bool:
	var next := get_skill_level(skill) + 1
	if phy_experience < skill.next_phy(next): return false
	if tec_experience < skill.next_tec(next): return false
	if mnd_experience < skill.next_mnd(next): return false
	return true

func consume_exp_to_skill(skill : Skill) -> bool:
	if not has_exp_to_skill(skill): return false
	var next := get_skill_level(skill) + 1
	phy_experience -= skill.next_phy(next)
	tec_experience -= skill.next_tec(next)
	mnd_experience -= skill.next_mnd(next)
	return true

#
# アイテム
#
func spawn_inventory(template : CtrlInventory, filter : Callable = func (_item : Item): return true) -> CtrlInventory:
	var ctrl_inventory : CtrlInventory = template.duplicate()
	ctrl_inventory.inventory = Inventory.new()
	for id in StaticData.items.keys():
		if not ctrl_inventory.inventory.get_prototree().has_prototype(id):
			ctrl_inventory.inventory.get_prototree().create_prototype(id)
	ctrl_inventory.set_meta("owner", self)
	for item in inventory: if filter.call(item):
		ctrl_inventory.inventory.add_item_automerge(item.to_inventory_item())
	ctrl_inventory.inventory.item_added.connect(
		func (_item: InventoryItem):
			inventory.clear()
			for inv_item in ctrl_inventory.inventory.get_items():
				for _i in inv_item.get_stack_size():
					inventory.append(Item.from_inventory_item(inv_item))
	)
	ctrl_inventory.inventory.item_removed.connect(
		func (_item: InventoryItem):
			inventory.clear()
			for inv_item in ctrl_inventory.inventory.get_items():
				for _i in inv_item.get_stack_size():
					inventory.append(Item.from_inventory_item(inv_item))
	)
	return ctrl_inventory

#
# ダイアログ
#
func load_dialogic_character(dch : DialogicCharacter) -> void:
	dch.display_name = actor_name
	dch.portraits["Default"] = {"data_str" : portrait}
	dch.default_portrait = "Default"
	dch.set_meta("actor", self)
