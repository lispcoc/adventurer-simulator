class_name BattleManager extends Node

signal exit_battle

@export var battle_command : UICommandSelector
@export var skill_select : UICommandSelector
@export var party_container : UIBattleActorContainer
@export var enemy_container : UIBattleActorContainer
@export var message : RichTextLabel

var party_front : Array[BattleActor]
var party_back : Array[BattleActor]
var enemies_front : Array[BattleActor]
var enemies_back : Array[BattleActor]

var can_escape : bool = true

var current_actor : BattleActor

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func init_test_data():
	party_front.append(BattleActorPlayer.new())
	party_front.append(BattleActorPlayer.new())
	party_front.append(BattleActorPlayer.new())
	party_back.append(BattleActorPlayer.new())
	var a = BattleActorEnemy.new()
	a.actor.level = 1
	enemies_front.append(a)
	enemies_back.append(BattleActorEnemy.new())

func start() -> void:
	reflesh_container()
	await main_loop()
	await Transition.cover(0.5)
	exit_battle.emit()
	queue_free.call_deferred()

func reflesh_container():
	party_container.erase_actors()
	enemy_container.erase_actors()
	for e in party_front: party_container.add_actor_front(e)
	for e in party_back: party_container.add_actor_back(e)
	for e in enemies_front: enemy_container.add_actor_front(e)
	for e in enemies_back: enemy_container.add_actor_back(e)

func get_party() -> Array[BattleActor]:
	return party_front + party_back

func get_enemies() -> Array[BattleActor]:
	return enemies_front + enemies_back

#
# Melee
#
func check_melee_hit(atkr, tgt) -> bool:
	return atkr.hit_roll() > tgt.dodge_roll()

func process_melee_attack(attacker : BattleActor, target : BattleActor, sk : Skill = null):
	set_msg("%sの攻撃\n" % attacker.actor_name)
	var total_damage = 0
	var times = attacker.actor.get_melee_times(sk)
	var hit = 0
	for _i in times:
		if check_melee_hit(attacker, target):
			var damage = attacker.actor.roll_melee_damage(sk)
			total_damage +=target.apply_dagame(damage)
			hit += 1
	target.floating_damage(total_damage)
	add_msg("%d回ヒットして%dのダメージ" % [hit, total_damage])
	await target.blink()

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

func select_target(target_type : SkillData.Target, range : int, by_front : bool):
	var targets : Array[BattleActor]
	if not by_front: range -= 1
	var front_valid : bool = range >= 1
	var back_valid : bool = range >= 2

	if target_type == SkillData.Target.PartyOne:
		return await party_container.start_select_target(true, true)
	if target_type == SkillData.Target.PartyLine:
		return await party_container.start_select_line(true, true)

	if not front_valid and not back_valid:
		set_msg("射程内に対象がいない")
		return targets
	if target_type == SkillData.Target.EnemyOne:
		return await enemy_container.start_select_target(front_valid, back_valid)
	if target_type == SkillData.Target.EnemyLine:
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
				var by_front : bool = party_front.has(c) || enemies_front.has(c)
				c.defence = false
				c.on_main_entered()
				if c.is_player():
					set_msg("%sの行動" % current_actor.actor_name)
					# スキルセレクタの構築
					skill_select.erase_commands()
					for sk in c.actor.skills:
						skill_select.add_command(sk.data.skill_name, {"skill" : sk})
					var accept = false
					while !accept:
						var ret = await battle_command.start_select()
						match ret["command"]:
							"Attack":
								var targets = await select_target(SkillData.Target.EnemyOne, 1, by_front)
								if not targets.is_empty() and !enemy_container.is_canceled:
									for t in targets:
										await process_melee_attack(c, t)
									accept = true
							"Skill":
								var sk : Skill = ret["skill"]
								var targets : Array[BattleActor] = await select_target(sk.data.target, sk.data.range, by_front)
								if not targets.is_empty() and !enemy_container.is_canceled:
									if sk.data.type == SkillData.Type.Melee:
										for t in targets:
											await process_melee_attack(c, t, sk)
									if sk.data.type == SkillData.Type.Magic:
										pass #todo
									accept = true
							"Defence":
								c.defence = true
								accept = true
							"Escape":
								if can_escape:
									return BattleResult.Run
									accept = true
								else:
									set_msg("逃げられない")
				if c.is_enemy():
					await process_melee_attack(c, party_container.pick_random(true, false))
				c.on_main_exit()
				c.available = false
			if is_dead_all(get_party()) || is_dead_all(get_enemies()):
				break
			if is_dead_all(party_front): swap_array(party_front, party_back)
			if is_dead_all(enemies_front): swap_array(enemies_front, enemies_back)
			reflesh_container()
		# Cleanup
		if is_dead_all(get_party()):
			return BattleResult.Lose
		if is_dead_all(get_enemies()):
			return BattleResult.Win
	return BattleResult.Win

func is_dead_all(actors : Array[BattleActor]):
	for e in actors: if !e.is_dead(): return false
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
