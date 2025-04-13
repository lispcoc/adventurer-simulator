class_name _CharacterPanelUI extends CanvasLayer

@export var character_panel_scene : PackedScene

func _ready() -> void:
	reflesh()
	Dialogic.timeline_started.connect(func (): hide())
	Dialogic.timeline_ended.connect(func (): show())

func reflesh() -> void:
	for c in $Container.get_children(): $Container.remove_child(c)
	for member in Game.get_party():
		var panel = character_panel_scene.instantiate() as CharacterPanel
		panel.actor = member
		$Container.add_child(panel)
