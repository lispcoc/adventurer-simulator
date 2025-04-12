@tool
class_name LabeledHSlider extends Control

@export var name_label : String:
	set(v):
		name_label = v
		if $Name: $Name.text = v

@export var slider_width : int = 50:
	set(v):
		slider_width = v
		_on_resized()

@export var min_value : int = 0:
	set(v):
		min_value = v
		_on_update()

@export var max_value : int = 100:
	set(v):
		max_value = v
		_on_update()

@export var value : int:
	set(v):
		if $Slider:
			$Slider.value = max(min(max_value, v), min_value)
			_on_update()
	get:
		if $Slider:
			return $Slider.value
		return 0

var slider : HSlider
var value_label : Label

func _init() -> void:
	resized.connect(_on_resized)

func _ready() -> void:
	$Slider.max_value = max_value
	$Slider.value_changed.connect(_on_value_changed)
	_on_update()
	_on_value_changed($Slider.value)

func _on_resized() -> void:
	$Slider.custom_minimum_size.x = size.x * slider_width / 100

func _on_update() -> void:
	$Slider.min_value = min_value
	$Slider.max_value = max_value
	$Slider.value = float(value)

func _on_value_changed(value : float) -> void:
	$Value.text = String.num_int64(int(value))
