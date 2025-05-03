class_name CharacterEdit extends Node2D

signal edit_ended()

const SCENE : PackedScene = preload("res://src/actor/character_edit.tscn")

var actor : Actor

static func instantiate() -> CharacterEdit: return SCENE.instantiate()

func _ready() -> void:
	actor = Actor.new()
	Game.editor_ended.connect(_update_portrait)
	%PortraitEditButton.pressed.connect(func ():
		Game.start_portrait_edit(actor)
	)
	%Accept.pressed.connect(_on_accept)
	for id in Actor.Status.Id.values():
		%Status.add(Actor.Status.string(id))
		var spin_value := SpinValue.new()
		spin_value._min = 6
		spin_value.value = actor.get_status(id)
		spin_value._max = 20
		spin_value.value_changed.connect(_on_value_changed.bind(id))
		%Status.add_child(spin_value)
	%NameEdit.placeholder_text = actor.actor_name
	%NameEdit.text_changed.connect(_on_name_changed)
	%NameEdit.grab_focus()
	update()
	show_help()

func show_help() -> void:
	var help := ControlHint.new()
	%Help.add_child(help)
	help.add_hint("direction_lr", "数値の増減")

func update() -> void:
	var bp = actor.get_usable_bonus_point() - actor.get_used_bonus_point()
	%BonusPoint.text = "残りボーナスポイント : %d" % [
		actor.get_usable_bonus_point() - actor.get_used_bonus_point(),
	]
	if bp < 0: %BonusPoint.add_theme_color_override("font_color", Color("red"))
	else: %BonusPoint.remove_theme_color_override("font_color")

func _on_name_changed(new_text : String) -> void:
	actor.actor_name = new_text

func _on_value_changed(value : int, id : Actor.Status.Id):
	actor.set_status(id, value)
	update()

func _on_accept():
	var bp = actor.get_usable_bonus_point() - actor.get_used_bonus_point()
	var message : String = "この能力でゲームを開始しますか？"
	if bp < 0: return
	if bp > 0: message = "未使用のボーナスポイントがあります。この能力でゲームを開始しますか？"
	var ret := await Game.query_yn(message)
	if not ret:
		%Accept.grab_focus()
		return
	edit_ended.emit()
	queue_free.call_deferred()

func _update_portrait():
	%Portrait.from_string(actor.portrait)
	%PortraitEditButton.grab_focus()
