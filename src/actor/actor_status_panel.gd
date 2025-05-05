class_name ActorStatusPanel extends TabContainer

const SCENE : PackedScene = preload("res://src/actor/actor_status_panel.tscn")

var portrait : Portrait
var text_l : RichTextLabel
var text_r : RichTextLabel
var base_status : TiledStringGrid
var weapon_info : TiledStringGrid
var closable : bool = false

static func instantiate() -> ActorStatusPanel:
	return SCENE.instantiate()

func _ready() -> void:
	portrait = %Portrait
	text_l = %TextL
	text_r = %TextR
	base_status = %BaseStatus
	weapon_info = %WeaponInfo

func _unhandled_input(event: InputEvent) -> void:
	if closable and event.is_action_released("ui_cancel"):
		queue_free.call_deferred()
		get_viewport().set_input_as_handled()

func update(actor : Actor) -> void:
	portrait.from_string(actor.portrait)
	update_base_status(actor)
	update_weapon_info(actor)
	text_l.text = status_text_left(actor)
	text_r.text = status_text_right(actor)

func update_base_status(actor : Actor) -> void:
	base_status.erase()
	var sex := " 男性 "
	if actor.sex == Actor.Sex.Female: sex = " 女性 "
	base_status.add_array([
		" 名前 ", " %s " % [actor.actor_name],
		" 性別 ", sex,
		" 職業 ", " %s " % [actor.get_class_data().display_name],
	])
	base_status.add_array([
		" Lv ", " %d " % [actor.level],
		" HP ", " %d/%d " % [actor.hp, actor.hp_max],
		" MP ", " %d/%d " % [actor.mp, actor.mp_max],
	])
	for id in Actor.Status.Id.values():
		base_status.add_array([
			" %s " % Actor.Status.string(id),
			" %d " % actor.get_status(id)
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
