class_name GamePopup extends CanvasLayer

signal pressed()

var default : bool = true
var ret : bool = true
var _last_focus : Control

const SCENE : PackedScene = preload("res://src/common/ui/popup/popup.tscn")

static func instantiate() -> GamePopup:
	return SCENE.instantiate()

func _ready() -> void:
	_last_focus = get_viewport().gui_get_focus_owner()
	%Yes.pressed.connect(_yes_pressed)
	%No.pressed.connect(_no_pressed)

func start(message : String, default_val : bool = true, yes_only : bool = false) -> bool:
	%Message.text = message
	if yes_only: %No.hide()
	if default_val: %Yes.grab_focus()
	else: %No.grab_focus()
	get_tree().paused = true
	await pressed
	get_tree().paused = false
	queue_free.call_deferred()
	if _last_focus: _last_focus.grab_focus()
	return ret

func _yes_pressed() -> void:
	ret = true
	pressed.emit()

func _no_pressed() -> void:
	ret = false
	pressed.emit()
