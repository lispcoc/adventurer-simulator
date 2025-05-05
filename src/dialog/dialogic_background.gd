extends DialogicBackground

func _ready() -> void:
	print(Dialogic.Backgrounds)
func _update_background(argument:String, time:float) -> void:
	print(argument)
