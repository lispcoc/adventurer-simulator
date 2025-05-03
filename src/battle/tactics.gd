class_name Tactics extends Node

static func enumulate_act(bm : BattleManager, actor : BattleActor) -> Array[BattleActor.Act]:
	var pf := bm.get_party_front()
	var pb := bm.get_party_back()
	var ef := bm.get_enemies_front()
	var eb := bm.get_enemies_back()
	if (ef + eb).has(actor):
		pf = bm.get_enemies_front()
		pb = bm.get_enemies_back()
		ef = bm.get_party_front()
		eb = bm.get_party_back()
	var by_front := pf.has(actor)
	var acts : Array[BattleActor.Act]
	for ability in actor.actor.get_actions(): if ability.data.in_battle:
		var target_range = ability.data.target_range
		if by_front: target_range = target_range + 1
		match ability.data.target_type:
			Game.Target.All:
				acts.append(BattleActor.Act.new(ability, pf + pb + ef + eb))
			Game.Target.Self:
				acts.append(BattleActor.Act.new(ability, [actor]))
			Game.Target.PartyAll:
				acts.append(BattleActor.Act.new(ability, pf + pb))
			Game.Target.PartyLine:
				if target_range >= 3 and not eb.is_empty():
					acts.append(BattleActor.Act.new(ability, pb))
				if target_range >= 2:
					acts.append(BattleActor.Act.new(ability, pf))
			Game.Target.PartyOne:
				var possible : Array[BattleActor]
				if target_range >= 3 and not eb.is_empty():
					possible = pf + pb
				elif target_range >= 2:
					possible = pf
				for t in possible: acts.append(BattleActor.Act.new(ability, [t]))
			Game.Target.EnemyAll:
				acts.append(BattleActor.Act.new(ability, ef + eb))
			Game.Target.EnemyLine:
				if target_range >= 3 and not eb.is_empty():
					acts.append(BattleActor.Act.new(ability, eb))
				if target_range >= 2:
					acts.append(BattleActor.Act.new(ability, ef))
			Game.Target.EnemyOne:
				var possible : Array[BattleActor]
				if target_range >= 3 and not eb.is_empty():
					possible = ef + eb
				elif target_range >= 2:
					possible = ef
				for t in possible: acts.append(BattleActor.Act.new(ability, [t]))
	return acts

static func evaluate_act(bm : BattleManager, actor : BattleActor, act : BattleActor.Act) -> int:
	var value := 0
	var is_hostile : bool
	for t in act.targets:
		is_hostile = bm.is_hostile(actor, t)
		var sim := t.spawn_simulator()
		var pre_value := sim.evaluate_threat()
		bm.process_ability(actor, [sim], act.ability, true)
		var post_value := sim.evaluate_threat()
		if is_hostile: value += pre_value - post_value
		else: value += post_value - pre_value
	return value
