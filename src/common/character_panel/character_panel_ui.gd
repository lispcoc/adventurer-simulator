class_name _CharacterPanelUI extends CanvasLayer

@export var character_panel_scene : PackedScene

func _ready() -> void:
	reload()

func reload() -> void:
	for c in $Container.get_children(): $Container.remove_child(c)
	for member in Game.get_party():
		var panel = character_panel_scene.instantiate() as CharacterPanel
		panel.actor = member
		$Container.add_child(panel)

func update() -> void:
	for p in $Container.get_children():
		p = p  as CharacterPanel
		p.update()

func get_panel(actor : Actor) -> CharacterPanel:
	for p in $Container.get_children():
		p = p  as CharacterPanel
		if p.actor == actor: return p
	return null
