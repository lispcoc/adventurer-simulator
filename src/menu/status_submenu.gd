class_name StatusSubMenu extends BaseSubmenuWithActor

var portrait : Portrait
var text_l : RichTextLabel
var text_r : RichTextLabel
var base_status : TiledStringGrid
var weapon_info : TiledStringGrid

func _ready() -> void:
	portrait = %Portrait
	text_l = %TextL
	text_r = %TextR
	base_status = %BaseStatus
	weapon_info = %WeaponInfo
	super._ready()

func on_focus_button(actor : Actor):
	portrait.from_string(actor.portrait)
	update_base_status(actor)
	update_weapon_info(actor)
	text_l.text = status_text_left(actor)
	text_r.text = status_text_right(actor)

func update_base_status(actor : Actor) -> void:
	base_status.erase()
	base_status.add(" 性別 ")
	if actor.sex == Actor.Sex.Male: base_status.add(" 男性 ")
	elif actor.sex == Actor.Sex.Female: base_status.add(" 女性 ")
	base_status.add_array([
		" Lv ", " %d " % [actor.level],
		" HP ", " %d/%d " % [actor.hp, actor.hp_max],
		" MP ", " %d/%d " % [actor.mp, actor.mp_max],
		" 筋力 ", " %d " % [actor.strength],
		" 耐久 ", " %d " % [actor.constitution],
		" 器用 ", " %d " % [actor.dexterity],
		" 魔力 ", " %d " % [actor.magic],
		" 精神 ", " %d " % [actor.mind],
	])

func update_weapon_info(actor : Actor) -> void:
	weapon_info.erase()
	weapon_info.add_array([
		" 武器 ", " %s " % actor.get_weapon().display_name(),
		" ダメージ ", " %s (%+d) " % [actor.get_weapon().get_melee_performance_string(), actor.get_atk()],
		" 攻撃回数 ", " %d " % [actor.get_melee_times()],
	])

# TODO: Actorに移動する
func status_text_left(_actor : Actor) -> String:
	var lines : PackedStringArray
	return "\n".join(lines)

func status_text_right(_actor : Actor) -> String:
	var lines : PackedStringArray
	return "\n".join(lines)
