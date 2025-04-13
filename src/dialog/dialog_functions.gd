extends Node

func _ready() -> void:
	Dialogic.signal_event.connect(recieve_signal)

func recieve_signal(arg : Dictionary) -> void:
	pass

func start_battle(monster_group : String) -> bool:
	DialogUi.hide()
	var ret = await Game.start_battle()
	DialogUi.show()
	Dialogic.VAR.Battle.Result = "Run"
	return ret

func add_party(character_templete_id : String) -> bool:
	var actor = Actor.new()
	Dialogic.VAR.RetVal.Success = Game.add_party(actor)
	return Dialogic.VAR.RetVal.Success
