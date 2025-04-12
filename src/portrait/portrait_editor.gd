class_name PortraitEditor extends Node2D

signal exit

var skin_slider : HSlider
var color_sliders : Dictionary
var color_slider_values : Dictionary
var skin_label_value : Label
var sliders : Dictionary
var values : Dictionary
var portrait : Portrait

func _ready() -> void:
	var grid : GridContainer = $CanvasLayer/Tab/Types/Grid
	var colors_grid : GridContainer = $CanvasLayer/Tab/Colors/Grid
	var label_name : Label
	var slider : HSlider
	var label_value : Label
	portrait = $CanvasLayer/Portrait

	label_name = Label.new()
	label_name.text = "肌"
	colors_grid.add_child(label_name)
	slider = HSlider.new()
	slider.custom_minimum_size.x = 64
	slider.max_value = portrait.skin_color_list.size() - 1
	colors_grid.add_child(slider)
	slider.value_changed.connect(_on_update)
	label_value = Label.new()
	colors_grid.add_child(label_value)
	skin_slider = slider
	skin_label_value = label_value

	for k in portrait.get_color_keys():
		label_name = Label.new()
		label_name.text = portrait.get_key_name(k)
		colors_grid.add_child(label_name)
		slider = HSlider.new()
		slider.custom_minimum_size.x = 64
		slider.max_value = portrait.get_color_count(k) - 1
		colors_grid.add_child(slider)
		label_value = Label.new()
		colors_grid.add_child(label_value)
		slider.value_changed.connect(_on_update)
		slider.value = portrait.colors[k]
		color_sliders[k] = slider
		color_slider_values[k] = label_value

	for k in portrait.get_keys():
		label_name = Label.new()
		label_name.text = portrait.get_key_name(k)
		grid.add_child(label_name)
		slider = HSlider.new()
		slider.custom_minimum_size.x = 64
		grid.add_child(slider)
		label_value = Label.new()
		grid.add_child(label_value)
		slider.value_changed.connect(_on_update)
		slider.value = portrait.data[k]
		sliders[k] = slider
		values[k] = label_value
	_on_update(0)
	var tc = $CanvasLayer/Tab as TabContainer
	tc.get_tab_bar().grab_focus()

func _process(_delta):
	if Input.is_action_pressed("ui_accept"):
		exit.emit()
		queue_free.call_deferred()
	if Input.is_action_pressed("ui_cancel"):
		exit.emit()
		queue_free.call_deferred()

func _on_update(_value : float):
	skin_label_value.text = String.num_int64(skin_slider.value)
	portrait.skin_color = skin_slider.value
	for k in color_sliders.keys():
		portrait.set_color(k, color_sliders[k].value)
		color_slider_values[k].text = String.num_int64(color_sliders[k].value)
	for k in sliders.keys():
		var slider : HSlider = sliders[k]
		sliders[k].max_value = portrait.num_parts[k] - 1
		values[k].text = String.num_int64(sliders[k].value)
		portrait.set_type(k, sliders[k].value)
	portrait.reflesh()
