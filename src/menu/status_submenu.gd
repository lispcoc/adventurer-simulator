class_name StatusSubMenu extends BaseSubmenuWithActor

var panel : ActorStatusPanel

func _ready() -> void:
	panel = ActorStatusPanel.instantiate()
	$CanvasLayer/Holder.add_child(panel)
	super._ready()

func on_focus_button(actor : Actor):
	panel.update(actor)
