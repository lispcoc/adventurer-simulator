class_name BattleActor extends Control

signal selected(actor : BattleActor)

var live : bool = false
var available : bool = false
var simulate : bool = false

var actor : Actor:
	set(_actor):
		actor = _actor
		on_set_actor()

var button : BaseButton
var cursor : Node2D

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
	get: return actor.mp_max
	set(val): pass
var mp : int:
	get: return actor.mp
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
	if not button: button = Button.new()
	add_child(button)

func _ready() -> void:
	live = true
	set_selectable(false)
	button.pressed.connect(_selected)

func _selected():
	selected.emit(self)

func on_set_hp(_val : int): pass

func on_set_mp(_val : int): pass

func on_dead(): pass

func on_set_actor(): pass

func on_main_entered(): pass

func on_main_exit(): pass

func on_status_update() -> void: pass

func set_selectable(v : bool):
	button.disabled = not v
	if v:
		button.focus_mode = Control.FOCUS_ALL
	else:
		button.focus_mode = Control.FOCUS_NONE
		remove_cursor()

func pop_cursor() -> void:
	cursor = Game.spawn_cursor()
	cursor.position = get_center_top()
	add_child(cursor)

func remove_cursor() -> void:
	for _cursor in get_children(): if Game.is_cursor(_cursor): remove_child(_cursor)

func focus():
	button.grab_focus()
	if button.is_visible_in_tree():
		return true
	return false

func blink():
	if simulate: return
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.05).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.05).set_trans(Tween.TRANS_ELASTIC)
	tween.set_loops(6)
	await tween.finished

func vanish():
	if simulate: return
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5).set_trans(Tween.TRANS_LINEAR)
	await tween.finished

func display_name() -> String:
	return actor.actor_name

func get_act(_by_front : bool, _enemy_front : Array[BattleActor], _enemy_back : Array[BattleActor]) -> Act:
	return null

func speed() -> int:
	return actor.dexterity

func is_ally() -> bool:
	return false

func is_enemy() -> bool:
	return false

func is_player() -> bool:
	return false

func is_dead() -> bool:
	return hp <= 0

func get_center_top() -> Vector2:
	return Vector2(size.x / 2, 0)

func hit_roll() -> int:
	return DiceRoller.roll_dices(1, 20) + actor.get_hit()

func get_hit() -> int:
	return actor.get_hit()

func dodge_roll() -> int:
	return DiceRoller.roll_dices(1, 20) + actor.get_dodge()

func get_dodge() -> int:
	return actor.get_dodge()

func apply_dagame(dam : Damage) -> int:
	var actual_damage : int
	if defence:
		dam.val = dam.val / 2
		actual_damage = actor.apply_dagame(dam)
	else:
		actual_damage = actor.apply_dagame(dam)
	if is_dead(): on_dead()
	on_status_update()
	return actual_damage

func floating_damage(val : int):
	var damage := FloatingDamage.instantiate()
	damage.text = String.num_uint64(val)
	damage.position = get_center_top()
	add_child(damage)

func evaluate_threat() -> int:
	var hp_rate : float = min(1.0, hp / (hp_max * 0.75))
	return int(actor.level * 100 * hp_rate)

func spawn_simulator() -> BattleActor:
	var sim : BattleActor = str_to_var(var_to_str(self))
	sim.simulate = true
	return sim


class Act:
	var ability : Ability
	var targets : Array[BattleActor]

	func _init(_ability : Ability = null, _targets : Array[BattleActor] = []) -> void:
		if _ability: ability = _ability
		if not _targets.is_empty(): targets = _targets
		
	func _to_string() -> String:
		var ret : String = ability.display_name()
		ret += ":"
		for t in targets: ret += " " + t.display_name()
		return ret
