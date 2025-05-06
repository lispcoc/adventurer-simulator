extends Node

var dialog_subwin_layer : CanvasLayer

func _ready() -> void:
	Dialogic.signal_event.connect(recieve_signal)
	dialog_subwin_layer = CanvasLayer.new()
	dialog_subwin_layer.layer = 20
	add_child(dialog_subwin_layer)

func recieve_signal(_arg : Dictionary) -> void:
	pass

func start_battle(_monster_group : String) -> bool:
	Dialogic.VAR.Battle.Result = "Run"
	return await Game.start_battle_test()

func start_battle_character() -> bool:
	var ret := true
	var dch := DialogicResourceUtil.get_character_resource("character")
	if dch.has_meta("actor"):
		var actor : Actor = dch.get_meta("actor", null)
		if actor is Actor:
			var front : Array[Actor]
			front.append(actor.deep_clone())
			ret = await Game.start_battle(front)
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

func show_status(character_idx : int) -> void:
	if character_idx == 0:
		var dch := DialogicResourceUtil.get_character_resource("character")
		if dch.get_meta("actor", null) is Actor:
			var panel := ActorStatusPanel.instantiate()
			panel.closable = true
			dialog_subwin_layer.add_child(panel)
			panel.update(dch.get_meta("actor"))
			await panel.tree_exited

func portrait_edit(character_idx : int) -> void:
	if character_idx == 0:
		var dch := DialogicResourceUtil.get_character_resource("character")
		if dch.get_meta("actor", null) is Actor:
			await Game.start_portrait_edit(dch.get_meta("actor"))
