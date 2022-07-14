extends Control

var datetime = DateTime.now()

var _delta_index := 0.0
var _speed := 1.0

onready var label = get_node("Label")


func _process(delta: float) -> void:
	_delta_index += delta
	if _delta_index >= 1.0:
		datetime = datetime.add_seconds(1)
		_delta_index = 0.0
	var text = (
		"it is the %s day\nof the year of our lord %s\nbeing the %s day of %s\n%s %s past the hour of %s"
		% [
			NumberToWords.to_ordinal(datetime.julian),
			NumberToWords.to_year(datetime.year),
			NumberToWords.to_ordinal(datetime.day),
			datetime.month_name,
			NumberToWords.to_words(datetime.minute),
			"minute" if datetime.minute == 1 else "minutes",
			NumberToWords.to_words(int(datetime.strftime("%I")))
		]
	)
	label.text = text
