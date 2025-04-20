class_name _ClockUI extends CanvasLayer

var panel : Panel
var time_label : RichTextLabel
var place_label : RichTextLabel

func _ready() -> void:
	panel = $Panel
	time_label = $Panel/Time
	place_label = $Panel/Place
	Game.get_time().on_pass_minute.connect(update)
	start()

func start():
	update()

func update():
	var time : GameTime = Game.get_time()
	time_label.text = time.string_format("YYYY年目 MM月DD日 hh:mm")

func set_place(s : String):
	place_label.text = s
