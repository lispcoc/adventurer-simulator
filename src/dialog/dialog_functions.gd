extends Node

func _ready() -> void:
	Dialogic.signal_event.connect(recieve_signal)

func recieve_signal(_arg : Dictionary) -> void:
	pass

func start_battle(_monster_group : String) -> bool:
	DialogUi.hide()
	var ret = await Game.start_battle()
	DialogUi.show()
	Dialogic.VAR.Battle.Result = "Run"
	return ret

func get_party() -> void:
	var i := 0
	for j in range(5):
		Dialogic.VAR.Party[str(i)]["Name"] = ""
	for a in Game.get_party():
		Dialogic.VAR.Party[str(i)]["Name"] = a.actor_name
		i = i + 1

func add_party(_character_templete_id : String) -> bool:
	var actor = Actor.new()
	Dialogic.VAR.RetVal.Success = Game.add_party(actor)
	return Dialogic.VAR.RetVal.Success

func remove_party(num : int) -> bool:
	var actor = Game.get_party()[num]
	Dialogic.VAR.RetVal.Success = Game.remove_party(actor)
	return Dialogic.VAR.RetVal.Success

func damage_party(val : int):
	Game.damage_party(Damage.new(val, Attribute.Type.None))
