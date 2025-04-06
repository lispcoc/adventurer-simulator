class_name BattleActorEnemy extends BattleActor

var default_sprite : Texture2D = preload("res://assets/monsters/Battlers/World01_001_GreenGoo.png")

var sprite : Sprite2D
var label : RichTextLabel
var label_panel : PanelContainer

func _init() -> void:
	super._init()
	sprite = Sprite2D.new()
	add_child(sprite)
	label_panel = PanelContainer.new()
	label_panel.position.y = 64
	label_panel.custom_minimum_size = Vector2(200, 32)
	label = RichTextLabel.new()
	label_panel.add_child(label)
	label_panel.hide()
	add_child(label_panel)

func _ready():
	super._ready()
	button.focus_entered.connect(on_focus_entered)
	button.focus_exited.connect(on_focus_exited)

	custom_minimum_size = Vector2(200, 64)
	sprite.texture = default_sprite
	sprite.position.x = custom_minimum_size.x / 2
	sprite.position.y = custom_minimum_size.y - sprite.texture.get_size().y / 2
	button.size = custom_minimum_size

func on_focus_entered():
	label_panel.show()
	label.text = name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pass

func on_focus_exited():
	label_panel.hide()

func on_dead():
	await vanish()
	hide()

func is_enemy() -> bool:
	return true
