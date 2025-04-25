class_name TiledStringGrid extends GridContainer

@export var odd_style : StyleBox
@export var even_style : StyleBox
@export var odd_color : Color
@export var even_color : Color
@export var font_size : int
@export var odd_minimum_size : Vector2
@export var even_minimum_size : Vector2
@export var odd_button : bool
@export var even_button : bool
@export var odd_alignment : HorizontalAlignment
@export var even_alignment : HorizontalAlignment

func erase() -> void:
	for c in get_children(): remove_child(c)

func add_array(array : PackedStringArray) -> void:
	for s in array: add(s)

func add(text : String) -> void:
	var control : Control
	var is_odd := get_children().size() % 2 == 0
	var alignment := even_alignment
	if is_odd: alignment = odd_alignment
	if (is_odd and odd_button) or (not is_odd and even_button):
		control = Button.new()
		(control as Button).alignment = alignment
	else:
		control = Label.new()
		(control as Label).horizontal_alignment = alignment
	var style := odd_style
	var color = odd_color
	control.custom_minimum_size = odd_minimum_size
	if not is_odd:
		style = even_style
		color = even_color
		control.custom_minimum_size = even_minimum_size
	control.text = text
	if font_size: control.add_theme_font_size_override("font_size", font_size)
	control.add_theme_stylebox_override("normal", style)
	control.add_theme_color_override("font_color", color)
	add_child(control)

func get_buttons() -> Array[Button]:
	var res : Array[Button]
	for c in get_children(): if c is Button: res.append(c)
	return res
