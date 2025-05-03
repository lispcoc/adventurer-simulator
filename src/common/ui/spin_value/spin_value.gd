class_name SpinValue extends HBoxContainer

signal value_changed(value : int)

const SCENE : PackedScene = preload("res://src/common/ui/spin_value/spin_value.tscn")

@export var _min : int = 0
@export var _max : int = 100
@export var value : int = 0:
	set(v):
		value = min(self._max, max(self._min, v))
		value_changed.emit(value)

var _button : Button

static func instantiate() -> SpinValue:
	return SCENE.instantiate()

func _ready() -> void:
	_button = Button.new()
	add_child(_button)
	_update()

func _update() -> void:
	_button.text = " %d " % value

func _input(_event: InputEvent) -> void:
	if _button.has_focus():
		if Input.is_action_pressed("ui_right"):
			_button.grab_focus()
			value += 1
			get_viewport().set_input_as_handled()
		if Input.is_action_pressed("ui_left"):
			_button.grab_focus()
			value -= 1
			get_viewport().set_input_as_handled()
		_update()
