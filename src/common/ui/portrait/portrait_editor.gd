extends Node2D

var skin_slider : HSlider
var color_sliders : Dictionary
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
		color_sliders[k] = slider
		values[k] = label_value
		slider.value = portrait.colors[k]

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
		sliders[k] = slider
		values[k] = label_value
		slider.value = portrait.data[k]
	_on_update(0)

func _on_update(_value : float):
	skin_label_value.text = String.num_int64(skin_slider.value)
	portrait.skin_color = skin_slider.value
	
	for k in portrait.data.keys():
		if not sliders.has(k): continue
		var slider : HSlider = sliders[k]
		slider.max_value = portrait.num_parts[k] - 1
		var label_value : Label = values[k]
		label_value.text = String.num_int64(slider.value)
		portrait.set_type(k, slider.value)
	portrait.reflesh()
