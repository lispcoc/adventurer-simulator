class_name Skill

var id = "null"

var data : SkillData:
	get: return StaticData.skills[id]
	set(_v): pass

func display_name() -> String:
	return data.display_name

func use(_user : Actor, _target : Actor) -> int:
	var val : int
	match data.effect:
		"heal_hp":
			val = DiceRoller.roll_dices(
				data.base_amount,
				data.base_sides,
				data.base_constant
			)
			_target.hp += val
	return val
