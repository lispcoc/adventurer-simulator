class_name SystemSubMenu extends Node2D

signal exit()

func _ready() -> void:
	%BattleMessageSpeed.grab_focus()
	%BattleMessageSpeed.value = Game.game_data.battle_message_speed
	%BattleMessageSpeed.value_changed.connect(func (value: float):
		Game.game_data.battle_message_speed = int(value)
	)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		exit.emit()
		queue_free.call_deferred()
		get_viewport().set_input_as_handled()
