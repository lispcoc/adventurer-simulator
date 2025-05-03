class_name BattleManager extends Node

signal exit_battle

@export var battle_command : UICommandSelector
@export var ability_select : UICommandSelector
@export var party_container : UIBattleActorContainer
@export var enemy_container : UIBattleActorContainer
@export var message : RichTextLabel
@export var portrait : Portrait

var can_escape : bool = true

var current_actor : BattleActor

func _ready() -> void:
	portrait_hide()

func _process(_delta: float) -> void:
	pass

func message_delay() -> void:
	await get_tree().create_timer(0.5).timeout

func init_test_data():
	var a = BattleActorEnemy.new()
	a.load_from_monster_data(StaticData.monsters["slime"])
	a.actor.level = 1
	enemy_container.add_actor_front(a)
	var b = BattleActorEnemy.new()
	b.load_from_monster_data(StaticData.monsters["slime"])
	b.actor.level = 1
	enemy_container.add_actor_back(b)

func start() -> void:
	for ch in Game.game_data.party_front:
		var ac = BattleActorPlayer.new()
		ac.actor = ch
		party_container.add_actor_front(ac)
	for ch in Game.game_data.party_back:
		var ac = BattleActorPlayer.new()
		ac.actor = ch
		party_container.add_actor_back(ac)
	await main_loop()
	await Transition.cover(0.5)
	exit_battle.emit()
	queue_free.call_deferred()

func get_party() -> Array[BattleActor]: return party_container.get_actors()
func get_party_front() -> Array[BattleActor]: return party_container.get_actors_front()
func get_party_back() -> Array[BattleActor]: return party_container.get_actors_back()
func get_enemies() -> Array[BattleActor]: return enemy_container.get_actors()
func get_enemies_front() -> Array[BattleActor]: return enemy_container.get_actors_front()
func get_enemies_back() -> Array[BattleActor]: return enemy_container.get_actors_back()

#
# Melee
#
func check_melee_hit(atkr : BattleActor, tgt : BattleActor) -> bool:
	print(75.0 * pow(2.0,  float(atkr.get_hit() - tgt.get_dodge()) / 10.0))
	return DiceRoller.roll_dices(1, 100) < 50.0 * pow(2.0,  float(atkr.get_hit() - tgt.get_dodge()) / 10.0)

func process_melee_attack(attacker : BattleActor, target : BattleActor, sk : Ability = null, simulate : bool = false):
	if not simulate:
		if not sk: set_msg("%sの攻撃\n" % attacker.display_name())
	var total_damage = 0
	var times = attacker.actor.get_melee_times(sk)
	var hit = 0
	for _i in times:
		if check_melee_hit(attacker, target):
			var damage = attacker.actor.roll_melee_damage(sk)
			total_damage += target.apply_dagame(damage)
			hit += 1
	if simulate:
		return
	if hit > 0:
		target.floating_damage(total_damage)
		add_msg("%d回ヒットして%dのダメージ\n" % [hit, total_damage])
		await target.blink()
	else:
		add_msg("%sは回避した。\n" % target.display_name())
		await message_delay()

func process_ability(attacker : BattleActor, targets : Array[BattleActor], ability : Ability, simulate : bool = false):
	if targets.is_empty():
		if not simulate:
			set_msg("%sは様子を見ている……。\n" % attacker.display_name())
			await message_delay()
		return
	if not simulate:
		if ability.data.use_msg.is_empty():
			set_msg("%sの%s\n" % [attacker.display_name(), ability.display_name()])
		else:
			set_msg(ability.data.use_msg.format({ "user" : attacker.display_name(), "ability_name" : ability.display_name()}))
			add_msg("\n")
	if ability.data.type == AbilityData.Type.Melee:
		for target in targets: await process_melee_attack(attacker, target, ability, simulate)
	if ability.data.type == AbilityData.Type.Magic:
		for target in targets:
			print(ability.data.effect)
			var value : int = await ability.use(attacker.actor, target.actor)
			add_msg(ability.data.result_msg.format({ "target" : target.display_name(), "value" : value}))
			add_msg("\n")
			await message_delay()

#
# Messages
#
func set_msg(text : String):
	message.text = text

func add_msg(text : String):
	message.text += text

func clr_msg(): set_msg("")

#
# turn manager
#
@warning_ignore("unused_signal")
signal exit_main_phase

enum Phase {
	Setup,
	Initiative,
	Main,
	Cleanup,
}

enum BattleResult {
	Win,
	Lose,
	Run,
}

func select_target(target_type : Game.Target, target_range : int, by_front : bool):
	var targets : Array[BattleActor]
	if not by_front: target_range -= 1
	var front_valid : bool = target_range >= 1
	var back_valid : bool = target_range >= 2

	if target_type == Game.Target.PartyOne:
		return await party_container.start_select_target(true, true)
	if target_type == Game.Target.PartyLine:
		return await party_container.start_select_line(true, true)

	if not front_valid and not back_valid:
		set_msg("射程内に対象がいない")
		return targets
	if target_type == Game.Target.EnemyOne:
		return await enemy_container.start_select_target(front_valid, back_valid)
	if target_type == Game.Target.EnemyLine:
		return await enemy_container.start_select_line(front_valid, back_valid)
	return targets

func main_loop() -> BattleResult:
	while !get_party().is_empty() && !get_enemies().is_empty():
		# Setup
		var initiative_list : Array[BattleActor] = get_party() + get_enemies()
		initiative_list.sort_custom(func(a, b): return a.speed() < b.speed())
		# Initiative
		for c in initiative_list:
			c.available = true
		for c in initiative_list:
			if !c.is_dead() && c.available:
				# Main
				current_actor = c
				var by_front : bool = party_container.get_actors_front().has(c) || enemy_container.get_actors_front().has(c)
				c.defence = false
				c.on_main_entered()
				if c.is_player():
					var act := pick_act(c)
					await process_ability(c, act.targets, act.ability)
				elif c.is_enemy():
					var act := pick_act(c)
					await process_ability(c, act.targets, act.ability)
				else: #npc
					if !current_actor.actor.portrait.is_empty():
						portrait.show()
						portrait.from_string(str(current_actor.actor.portrait))
					else: portrait.hide()
					await portrait_fade_in()
					set_msg("%sの行動" % current_actor.display_name())
					# スキルセレクタの構築
					ability_select.erase_commands()
					for sk in c.actor.get_abilities():
						ability_select.add_command(sk.data.display_name, {"ability" : sk})
					var accept = false
					while !accept:
						var ret = await battle_command.start_select()
						match ret["command"]:
							"Attack":
								var targets = await select_target(Game.Target.EnemyOne, 1, by_front)
								if not targets.is_empty() and !enemy_container.is_canceled:
									for t in targets:
										await process_melee_attack(c, t)
									accept = true
							"Ability":
								var sk : Ability = ret["ability"]
								var targets : Array[BattleActor] = await select_target(sk.data.target_type, sk.data.target_range, by_front)
								if not targets.is_empty():
									await process_ability(c, targets, sk)
									accept = true
							"Defence":
								c.defence = true
								accept = true
							"Escape":
								if can_escape:
									return BattleResult.Run
								else:
									set_msg("逃げられない")
				portrait_hide()
				c.on_main_exit()
				c.available = false
			if is_dead_all(get_party()) || is_dead_all(get_enemies()):
				break
			party_container.reflesh()
			enemy_container.reflesh()
		# Cleanup
		if is_dead_all(get_party()):
			return BattleResult.Lose
		if is_dead_all(get_enemies()):
			return BattleResult.Win
	return BattleResult.Win

func pick_act(actor : BattleActor) -> BattleActor.Act:
	var act : BattleActor.Act
	var max_value := 0
	for a in Tactics.enumulate_act(self, actor):
		var value := Tactics.evaluate_act(self, actor, a)
		print(a)
		print("  %d" % value)
		if value >= max_value:
			max_value = value
			act = a
	print("-> %s" % act)
	return act

func is_dead_all(actors : Array[BattleActor]):
	for e in actors: if !e.is_dead(): return false
	return true

func is_hostile(a1 : BattleActor, a2 : BattleActor) -> bool:
	if get_party().has(a1) and get_party().has(a2): return false
	if get_enemies().has(a1) and get_enemies().has(a2): return false
	return true

func swap_array(a : Array[BattleActor], b : Array[BattleActor]):
	var tmp : Array[BattleActor]
	tmp.append_array(a)
	a.clear()
	a.append_array(b)
	b.clear()
	b.append_array(tmp)

func get_phase() -> Phase:
	return Phase.Initiative

func portrait_hide():
	var portrait_container : Container = portrait.get_parent() as Control
	portrait_container.hide()
	
func portrait_fade_in():
	var portrait_container : Container = portrait.get_parent() as Control
	portrait_container.show()
	var pos = portrait_container.position
	portrait_container.position.x = -portrait_container.size.x
	var tween = get_tree().create_tween()
	tween.tween_property(portrait.get_parent(), "position", pos, 0.05)
	await tween.finished
