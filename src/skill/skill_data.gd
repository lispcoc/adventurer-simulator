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

enum Target {
	EnemyOne,
	EnemyLine,
	EnemyAll,
	PartyOne,
	PartyLine,
	PartyAll,
	Self,
	All
}

var id : String = "null"
var skill_name : String = "null"
var category : Category = Category.Attack
var type : Type = Type.Melee
var range : int = 1
var target : Target = Target.EnemyOne
var effect : Callable = f_default
# Melee
var melee_damage_mul : float = 1.0
var melee_time_override : int = 0
# Magic
var flags : Array[int]

static func load(list : Dictionary, path : String):
	var database = SkillDataTextDatabase.new()
	database.id_name = "no"
	database.load_from_path(path)
	list.merge(database.get_struct_dictionary(), true)

func from_db(db : Dictionary):
	id = db["id"]
	skill_name = db["name"]
	type = Type.keys().find(db["type"]) as Type
	if type == -1:
		print("Invalid skill type")
		type = Type.Melee

	range = db["range"]
	target = Target.keys().find(db["target"]) as Target
	if target == -1:
		print("Invalid skill target")
		target = Target.EnemyOne

	melee_damage_mul = db["melee_damage_mul"]
	melee_time_override = db["melee_time_override"]

func instantiate() -> Skill:
	var s = Skill.new()
	s.data = self
	return s

static func map_effect(effect_id : String):
	var map = {
		"heal_hp": f_heal_hp
	}
	return map[effect_id]

static func f_default(_sk : Skill, _user, _target):
	print("Warning: Skill has no function.")
	return false

static func f_heal_hp(_sk : Skill, _user, _target):
	return true


class SkillDataTextDatabase extends TextDatabase:
	func _initialize():
		id_name = "no"
		entry_name = "skill_name"
		define_from_struct(SkillData.new)

	func _schema_initialize():
		override_property_type("category", TYPE_STRING)
		override_property_type("type", TYPE_STRING)
		override_property_type("target", TYPE_STRING)
		override_property_type("effect", TYPE_STRING)

	func _postprocess_entry(entry: Dictionary):
		entry.id = entry.skill_name
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
		if "target" in entry:
			for i in SkillData.Target.keys().size():
				if SkillData.Target.keys()[i] == entry.target:
					entry.target = i
					break
		if "effect" in entry:
			entry.effect = SkillData.map_effect(entry.effect)
