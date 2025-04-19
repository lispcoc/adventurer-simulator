class_name GameScene extends Node2D

signal scene_start()
signal scene_end()

func start():
	scene_start.emit()

func end():
	Game.end_current_scene()
	scene_end.emit()
	queue_free.call_deferred()

func disable(): hide()

func enable(): show()
