class_name StatusCondision

enum {
	Bleed,
	Blind,
	Brank,
	Burn,
	Charm,
	Confuse,
	Curse,
	Dead,
	Freeze,
	Oil,
	Paralyze,
	Poison,
	Silence,
	Sleep,
	Stan,
}

static func to_one_string_label(v : int) -> Label:
	var label = Label.new()
	label.text = to_one_string(v)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color("white"))
	return label

static func to_one_string(v : int):
	match v:
		Bleed: return "血"
		Blind: return "暗"
		Brank: return "?"
		Burn: return "炎"
		Charm: return "魅"
		Confuse: return "乱"
		Curse: return "呪"
		Dead: return "死"
		Freeze: return "氷"
		Oil: return "油"
		Paralyze: return "痺"
		Poison: return "毒"
		Silence: return "黙"
		Sleep: return "眠"
		Stan: return "止"
	return "？"
