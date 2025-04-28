class_name SkillData extends RefCounted

enum Category {
	Attack,
	Heal,
	Special,
	Others,
}

enum Type {
	Melee,
	Magic,
}

var id : String = "null"
var display_name : String = "null"
var category : Category = Category.Attack
var type : Type = Type.Melee
var target_range : int = 1
var target_type : Game.Target = Game.Target.EnemyOne
var effect : String = "default"
var in_battle : bool = true
var outside_of_battle : bool = false
# Messages
var use_msg : String
var result_msg : String
# Melee
var melee_damage_mul : float = 1.0
var melee_time_override : int = 0
# Magic
var base_amount : int = 2
var base_sides : int = 4
var base_constant : int = 0
var flags : Array[int]

static func load(list : Dictionary, path : String):
	var database = SkillDataTextDatabase.new()
	database.id_name = "no"
	database.load_from_path(path)
	list.merge(database.get_struct_dictionary(), true)

func instantiate() -> Skill:
	var s = Skill.new()
	s.id = id
	return s

static func map_effect(effect_id : String) -> Callable:
	var map : Dictionary[String, Callable] = {
		"heal_hp": f_heal_hp
	}
	return map[effect_id]

static func f_default(_sk : Skill, _user : BattleActor, _target : BattleActor) -> int:
	print("Warning: Skill has no function.")
	return 0

static func f_heal_hp(_sk : Skill, _user : Actor, _target : Actor) -> int:
	var val := DiceRoller.roll_dices(
		_sk.data.base_amount,
		_sk.data.base_sides,
		_sk.data.base_constant
	)
	_target.hp += val
	return true


class SkillDataTextDatabase extends TextDatabase:
	func _initialize():
		id_name = "no"
		entry_name = "id"
		define_from_struct(SkillData.new)

	func _schema_initialize():
		override_property_type("category", TYPE_STRING)
		override_property_type("type", TYPE_STRING)
		override_property_type("target_type", TYPE_STRING)

	func _postprocess_entry(entry: Dictionary):
		#entry.id = entry.skill_name
		if "category" in entry:
			for i in SkillData.Category.keys().size():
				if SkillData.Category.keys()[i] == entry.category:
					entry.category = i
					break
		if "type" in entry:
			for i in SkillData.Type.keys().size():
				if SkillData.Type.keys()[i] == entry.type:
					entry.type = i
					break
		if "target_type" in entry:
			for i in Game.Target.keys().size():
				if Game.Target.keys()[i] == entry.target_type:
					entry.target_type = i
					break
