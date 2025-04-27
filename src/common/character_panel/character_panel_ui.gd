class_name _CharacterPanelUI extends CanvasLayer

signal pressed(actor : Actor)
signal canceled()

@export var character_panel_scene : PackedScene

var processing : bool = false

func _ready() -> void:
	reload()
	get_viewport().gui_focus_changed.connect(_on_focus_changed)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		for p in $Container.get_children(): if p is CharacterPanel:
			if p.has_focus():
				p.release_focus()
				end_select()
				get_viewport().set_input_as_handled()

func _on_focus_changed(_node : Node) -> void:
	if processing:
		#フォーカスが外れたらキャンセル終了
		for p in $Container.get_children(): if p is CharacterPanel:
			if p.has_focus():
				return
		end_select()

func reload() -> void:
	for c in $Container.get_children(): $Container.remove_child(c)
	for member in Game.get_party():
		var panel = character_panel_scene.instantiate() as CharacterPanel
		panel.actor = member
		$Container.add_child(panel)
		panel.pressed.connect(_on_pressed.bind(member))

func update() -> void:
	for p in $Container.get_children():
		p = p  as CharacterPanel
		p.update()

func get_panel(actor : Actor) -> CharacterPanel:
	for p in $Container.get_children():
		p = p  as CharacterPanel
		if p.actor == actor: return p
	return null

func _on_pressed(actor : Actor) -> void:
	pressed.emit(actor)

func start_select() -> void:
	for p in $Container.get_children(): if p is CharacterPanel:
		p.selectable = true
	$Container.get_children()[0].grab_focus()
	layer = 20
	processing = true

func end_select() -> void:
	for p in $Container.get_children(): if p is CharacterPanel:
		p.selectable = false
	canceled.emit()
	layer = 3
	processing = false
