class_name BattleActor extends Control

signal selected(actor : BattleActor)

var live : bool = false
var available : bool = false

var actor : Actor

var button : Button

var selectable : bool = false:
	set(a):
		selectable = a
		if selectable:
			button.show()
		else:
			button.hide()

#
# Status
#
var hp_max : int:
	get: return actor.hp_max
	set(val): pass
var hp : int:
	get: return actor.hp
	set(val):
		actor.hp = max(0, val)
		on_set_hp(val)
		if hp <= 0: on_dead()

func _init() -> void:
	button = Button.new()
	button.hide()
	add_child(button)

func _ready() -> void:
	actor = Actor.new()
	live = true
	selectable = false
	button.pressed.connect(_selected)

func _selected():
	print("selected")
	emit_signal("selected", self)

func on_set_hp(_val : int):
	pass

func on_dead():
	pass

func focus():
	print("focus")
	button.grab_focus()

func blink():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.05).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.05).set_trans(Tween.TRANS_ELASTIC)
	tween.set_loops(6)
	await tween.finished

func vanish():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5).set_trans(Tween.TRANS_LINEAR)
	await tween.finished

func speed() -> int:
	return actor.dexterity

func is_player() -> bool:
	return false

func is_enemy() -> bool:
	return false

func is_dead() -> bool:
	return hp <= 0

func roll_melee_damage() -> int:
	return 100
