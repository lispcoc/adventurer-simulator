class_name UIStatusCondision extends Node

@export var dead : Texture2D = load("res://assets/gui/icons/condition/dead.png")
@export var poison : Texture2D = null
@export var paralyze : Texture2D = null

const rsc_map = {
	StatusCondision.Bleed : "res://assets/gui/icons/condition/bleed.png",
	StatusCondision.Blind : "res://assets/gui/icons/condition/blind.png",
	StatusCondision.Brank : "res://assets/gui/icons/condition/brank.png",
	StatusCondision.Burn : "res://assets/gui/icons/condition/burn.png",
	StatusCondision.Charm : "res://assets/gui/icons/condition/charm.png",
	StatusCondision.Confuse : "res://assets/gui/icons/condition/confuse.png",
	StatusCondision.Curse : "res://assets/gui/icons/condition/curse.png",
	StatusCondision.Dead : "res://assets/gui/icons/condition/dead.png",
	StatusCondision.Freeze : "res://assets/gui/icons/condition/freeze.png",
	StatusCondision.Oil : "res://assets/gui/icons/condition/oil.png",
	StatusCondision.Paralyze : "res://assets/gui/icons/condition/paralyze.png",
	StatusCondision.Poison : "res://assets/gui/icons/condition/poison.png",
	StatusCondision.Silence : "res://assets/gui/icons/condition/paralyze.png",
	StatusCondision.Sleep : "res://assets/gui/icons/condition/sleep.png",
	StatusCondision.Stan : "res://assets/gui/icons/condition/stan.png",
}

var conditions : Array[int] = []

func _ready() -> void:
	pass

func update() -> void:
	for n in self.get_children():
		self.remove_child(n)
		n.queue_free()
	var i = 0
	for c in conditions:
		var sp := Sprite2D.new()
		sp.texture = load(rsc_map[c])
		sp.position.x = 16 + i * 32
		sp.position.y = 16
		self.add_child(sp)
		i += 1

func add_condition(cond: int) -> void:
	if not conditions.has(cond):
		conditions.append(cond)
	update()

func remove_condition(cond: int) -> void:
	if conditions.has(cond):
		conditions.erase(cond)
	update()
