class_name GameStaticData extends Node

signal loaded

var classes : Dictionary[String, Class] = {}
var abilities : Dictionary[String, AbilityData] = {}
var skills : Dictionary[String, Skill] = {}
var items : Dictionary[String, ItemData] = {}
var monsters : Dictionary[String, MonsterData] = {}
var names : NameList

func _ready() -> void:
	print("GameStaticData._ready")
	load_classes()
	load_abilities()
	load_skills()
	load_items()
	load_names()
	load_monsters()
	emit_signal("loaded")

func load_classes():
	Class.load(classes, "res://data/json/classes.cfg")
	Class.load(classes, "res://data/json/classes_monster.cfg")
	print(classes)

func load_skills():
	Skill.load(skills, "res://data/json/skills.cfg")
	print(skills)

func load_abilities():
	AbilityData.load(abilities, "res://data/json/abilities.cfg")
	print(abilities)

func load_items():
	ItemData.load(items, "res://data/json/items.cfg")
	print(items)

func load_names():
	names = NameList.new()
	names.load("res://data/name/actor_names.cfg")

func load_monsters():
	MonsterData.load(monsters, "res://data/json/monsters.cfg")
	print(monsters)

func item_from_id(id : String) -> ItemData:
	return items[id]

func ability_from_id(id : String) -> AbilityData:
	return abilities[id]
