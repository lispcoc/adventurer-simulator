class_name ControlHint extends GridContainer

func _init() -> void:
	columns = 2

func add_hint(key_id : StringName, hint : String) -> void:
	var btn := TextureButton.new()
	btn.texture_normal = SpriteManager.load_controller_button(key_id)
	btn.scale = Vector2(8, 8) / btn.texture_normal.get_size()
	btn.focus_mode = Control.FOCUS_NONE
	add_child(btn)
	var label := Label.new()
	label.text = hint
	label.add_theme_font_size_override("font_size", 12)
	add_child(label)
