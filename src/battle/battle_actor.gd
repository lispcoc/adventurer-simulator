class_name BattleActor extends Control

signal selected(actor : BattleActor)

const FD : PackedScene = preload("res://src/battle/ui/number/floating_damage.tscn")

var live : bool = false
var available : bool = false

var actor : Actor:
	set(_actor):
		actor = _actor
		on_set_actor()

var button : Button

var selectable : bool = false:
	set(a):
		selectable = a
		if selectable:
			button.show()
		else:
			button.hide()

var actor_name : String:
	get:
		if actor: return actor.actor_name
		return ""

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
var mp_max : int:
	get: return actor.hp_max
	set(val): pass
var mp : int:
	get: return actor.hp
	set(val):
		actor.mp = max(0, val)
		on_set_mp(val)

#
# State
#
var defence : bool = false

#
# Functions
#
func _init() -> void:
	button = Button.new()
	add_child(button)

func _ready() -> void:
	button.hide()
	live = true
	selectable = false
	button.pressed.connect(_selected)

func _selected():
	selected.emit(self)

func on_set_hp(_val : int): pass

func on_set_mp(_val : int): pass

func on_dead(): pass

func on_set_actor(): pass

func on_main_entered(): pass

func on_main_exit(): pass

func focus():
	button.grab_focus()
	if button.is_visible_in_tree():
		return true
	return false

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

func get_center_pos() -> Vector2:
	return Vector2(0, 0)

func hit_roll() -> int:
	return DiceRoller.roll_dices(1, 20) + actor.get_hit()

func dodge_roll() -> int:
	return DiceRoller.roll_dices(1, 20) + actor.get_dodge()

func apply_dagame(dam : Damage) -> int:
	if defence:
		hp -= dam.val / 2
		return dam.val / 2
	else:
		hp -= dam.val
	return dam.val

func floating_damage(val : int):
	var damage := FD.instantiate() as FloatingDamage
	damage.text = String.num_uint64(val)
	damage.position = get_center_pos()
	add_child(damage)
