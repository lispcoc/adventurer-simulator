class_name TiledStringGrid extends GridContainer

@export var odd_style : StyleBox
@export var even_style : StyleBox
@export var odd_color : Color
@export var even_color : Color

func erase() -> void:
	for c in get_children(): remove_child(c)

func add_array(array : PackedStringArray) -> void:
	for s in array: add(s)

func add(text : String) -> void:
	var l = Label.new()
	l.text = text
	add_child(l)
	var style := odd_style
	var color = odd_color
	if get_children().size() % 2 == 0:
		style = even_style
		color = even_color
	l.add_theme_stylebox_override("normal", style)
	l.add_theme_color_override("font_color", color)
