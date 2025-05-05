extends DialogicLayoutBase


#func _ready() -> void:
	#Dialogic.timeline_started.connect(func(): show())
	#Dialogic.timeline_ended.connect(func(): hide())
