class_name BaseSubmenuWithActor extends Node2D

signal selected(actor : Actor)
signal focused(actor : Actor)
signal exit()
signal resume_actor_select()

var selector : UIGenericSelector

func _ready() -> void:
	selector = $CanvasLayer/ActorSelector
	var first := true
	for actor in Game.get_party():
		selector.add_command(actor.actor_name, "none", [actor], on_focus_button.bind(actor))
	while true:
		var ret := await selector.start_select()
		if selector.parse_retval(ret).canceled: break
		else:
			await on_selected(selector.parse_retval(ret).args[0])
	queue_free.call_deferred()
	exit.emit()

func on_selected(actor : Actor):
	selected.emit(actor)

func on_focus_button(actor : Actor):
	focused.emit(actor)
