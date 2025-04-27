class_name Skill

class SkillCheck:
	var success : bool
	var fail_message : String
	func _init(_success : bool, _fail_message : String = "") -> void:
		success = _success
		fail_message = _fail_message

var id = "null"

var data : SkillData:
	get: return StaticData.skills[id]
	set(_v): pass

func display_name() -> String:
	return data.display_name

func can_use(_user : Actor, _target : Actor) -> SkillCheck:
	return SkillCheck.new(true)

func use(_user : Actor, target : Actor) -> int:
	var val : int
	match data.effect:
		"heal_hp":
			val = DiceRoller.roll_dices(
				data.base_amount,
				data.base_sides,
				data.base_constant
			)
			target.heal_hp(val)
	return val
