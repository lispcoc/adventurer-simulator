class_name GameTime extends Node

signal on_pass_second
signal on_pass_minute
signal on_pass_hour
signal on_pass_day
signal on_pass_mon
signal on_pass_year

var second = 0
var minute = 0
var hour = 0
var day = 1
var mon = 1
var year = 1

func pass_second() -> void:
	second += 1
	on_pass_second.emit()
	if second >= 60:
		second -= 60
		pass_minute()

func pass_minute() -> void:
	minute += 1
	on_pass_minute.emit()
	if minute >= 60:
		minute -= 60
		pass_hour()

func pass_hour() -> void:
	hour += 1
	on_pass_hour.emit()
	if hour >= 24:
		hour -= 24
		pass_day()

func pass_day() -> void:
	day += 1
	on_pass_day.emit()
	if day > 30:
		day -= 30
		pass_mon()

func pass_mon() -> void:
	mon += 1
	on_pass_mon.emit()
	if mon > 12:
		day -= 12
		pass_year()

func pass_year() -> void:
	year += 1
	on_pass_year.emit()

func string_format(fmt : String):
	fmt = fmt.replace("YYYY", "%2d" % year)
	fmt = fmt.replace("MM", "%2d" % mon)
	fmt = fmt.replace("DD", "%2d" % day)
	fmt = fmt.replace("hh", "%02d" % hour)
	fmt = fmt.replace("mm", "%02d" % minute)
	fmt = fmt.replace("ss", "%02d" % second)
	return fmt
