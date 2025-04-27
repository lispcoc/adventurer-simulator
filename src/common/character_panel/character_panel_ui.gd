class_name _CharacterPanelUI extends CanvasLayer

signal pressed(targets : Array[Actor])
signal canceled()

@export var character_panel_scene : PackedScene

var processing : bool = false
var select_all : bool = false

func _ready() -> void:
	reload()
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	%AllButton.pressed.connect(_on_all_pressed)
	%AllButton.hide()

func _unhandled_input(_event: InputEvent) -> void:
	if processing:
		if Input.is_action_pressed("ui_cancel"):
			for panel in $Container.get_children(): if panel is CharacterPanel:
				if panel.has_focus():
					panel.release_focus()
					end_select()
					get_viewport().set_input_as_handled()
			if %AllButton.has_focus():
				%AllButton.release_focus()
				end_select()
				get_viewport().set_input_as_handled()

func _on_focus_changed(_node : Node) -> void:
	if processing:
		#フォーカスが外れたらキャンセル終了
		for p in $Container.get_children(): if p is CharacterPanel:
			if p.has_focus(): return
		if %AllButton.has_focus(): return
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
	var targets : Array[Actor]
	targets.append(actor)
	pressed.emit(targets)

func _on_all_pressed() -> void:
	pressed.emit(Game.get_party())

func start_select(all : bool = false) -> void:
	if all:
		for p in $Container.get_children(): if p is CharacterPanel:
			p.pop_cursor()
		select_all = true
		%AllButton.size = $Container.size
		%AllButton.position = $Container.position
		%AllButton.show()
		%AllButton.grab_focus()
	else:
		for p in $Container.get_children(): if p is CharacterPanel:
			p.selectable = true
		$Container.get_children()[0].grab_focus()
	layer = 20
	processing = true

func end_select() -> void:
	for p in $Container.get_children(): if p is CharacterPanel:
		p.selectable = false
		p.remove_cursor()
	canceled.emit()
	layer = 3
	processing = false
	select_all = false
	%AllButton.hide()
