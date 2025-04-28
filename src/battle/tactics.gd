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
	for skill in actor.actor.get_skills(): if skill.data.in_battle:
		var range = skill.data.range
		if by_front: range = range + 1
		match skill.data.target:
			Game.Target.All:
				acts.append(BattleActor.Act.new(skill, pf + pb + ef + eb))
			Game.Target.Self:
				acts.append(BattleActor.Act.new(skill, [actor]))
			Game.Target.PartyAll:
				acts.append(BattleActor.Act.new(skill, pf + pb))
			Game.Target.PartyLine:
				if range >= 3 and not eb.is_empty():
					acts.append(BattleActor.Act.new(skill, pb))
				if range >= 2:
					acts.append(BattleActor.Act.new(skill, pf))
			Game.Target.PartyOne:
				var possible : Array[BattleActor]
				if range >= 3 and not eb.is_empty():
					possible = pf + pb
				elif range >= 2:
					possible = pf
				for t in possible: acts.append(BattleActor.Act.new(skill, [t]))
			Game.Target.EnemyAll:
				acts.append(BattleActor.Act.new(skill, ef + eb))
			Game.Target.EnemyLine:
				if range >= 3 and not eb.is_empty():
					acts.append(BattleActor.Act.new(skill, eb))
				if range >= 2:
					acts.append(BattleActor.Act.new(skill, ef))
			Game.Target.EnemyOne:
				var possible : Array[BattleActor]
				if range >= 3 and not eb.is_empty():
					possible = ef + eb
				elif range >= 2:
					possible = ef
				for t in possible: acts.append(BattleActor.Act.new(skill, [t]))
	return acts

static func evaluate_act(bm : BattleManager, actor : BattleActor, act : BattleActor.Act) -> int:
	var value := 0
	var is_hostile : bool
	for t in act.targets:
		is_hostile = bm.is_hostile(actor, t)
		var sim := t.spawn_simulator()
		var pre_value := sim.evaluate_threat()
		bm.process_skill(actor, [sim], act.skill, true)
		var post_value := sim.evaluate_threat()
		if is_hostile: value += pre_value - post_value
		else: value += post_value - pre_value
	return value
