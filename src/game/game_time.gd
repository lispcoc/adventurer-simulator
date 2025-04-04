class_name GameTime extends Node
var second = 0
var minute = 0
var hour = 0
var day = 1
var mon = 1
var year = 1

func pass_second() -> void:
	second += 1
	if second >= 60:
		second -= 60
		pass_minute()

func pass_minute() -> void:
	minute += 1
	if minute >= 60:
		minute -= 60
		pass_hour()

func pass_hour() -> void:
	hour += 1
	if hour >= 24:
		hour -= 24
		pass_day()

func pass_day() -> void:
	day += 1
	if day > 30:
		day -= 30
		pass_mon()

func pass_mon() -> void:
	mon += 1
	if mon > 12:
		day -= 12
		pass_year()

func pass_year() -> void:
	year += 1
