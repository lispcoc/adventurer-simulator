extends Node2D

var panel : Panel
var v_container : VBoxContainer

var item : Item: set = set_item
var label_settings : LabelSettings

func _ready() -> void:
	label_settings = $ReferenceLabel.label_settings
	panel = $Panel
	v_container = VBoxContainer.new()
	v_container.position.x = 8
	panel.add_child(v_container)
	print(StaticData.item_from_id("sword"))
	item = StaticData.item_from_id("sword").instantiate()

func update():
	add_base_text()
	match item.data.type:
		ItemData.Type.Weapon:
			add_melee_text()

func add_base_text():
	add_line(item.display_name())
	add_line("重量:%d" % item.data.wgt)

func add_melee_text():
	add_line("ダメージ:%dd%d+%d 基礎攻撃回数:%d"
		% [item.data.melee_base_amount, item.data.melee_base_sides, item.data.melee_base_attack, item.data.melee_base_times])

func add_line(text : String):
	var label : Label = Label.new()
	label.text = text
	label.label_settings = label_settings
	v_container.add_child(label)

func set_item(_item):
	item = _item
	update()

func close():
	queue_free.call_deferred()
