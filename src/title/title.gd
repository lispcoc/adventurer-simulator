class_name TitleMenu extends CanvasLayer

const SCENE : PackedScene = preload("res://src/title/title.tscn")

signal continue_pressed()
signal loadgame_pressed()
signal newgame_pressed()

static func instantiate() -> TitleMenu:
	return SCENE.instantiate()

func _ready() -> void:
	%Continue.pressed.connect(
		func ():
			continue_pressed.emit()
			queue_free.call_deferred()
	)
	%LoadGame.pressed.connect(func (): print("Not implemented."))
	%NewGame.pressed.connect(
		func ():
			newgame_pressed.emit()
			queue_free.call_deferred()
	)
	%Continue.grab_focus()
