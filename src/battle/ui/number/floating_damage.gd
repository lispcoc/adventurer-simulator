class_name FloatingDamage extends Marker2D

var label : Label

var velocity = Vector2(0,-120)
var gravity = Vector2(0,2)
var mass = 100
var text_scale = Vector2.ONE * 1
var text: String:
	get: return $Label.text
	set(value): $Label.text = value

func _init() -> void:
	label = Label.new()
	add_child(label)

func _ready() -> void:
	# 左右にずらす
	velocity.x = randi_range(-3,3)

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	# 文字を徐々に透明にする
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0), 0.8)
	# 文字を大きくする
	tween.parallel()
	tween.tween_property(self, "scale", text_scale, 0.2)
	tween.tween_callback(_destory)

func _process(delta: float) -> void:
	velocity += gravity * mass * delta
	position += velocity * delta

func _destory() -> void:
	queue_free()
