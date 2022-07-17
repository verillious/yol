extends Control

var _delta_index := 0.0
var _speed := 1.0

onready var label = find_node("Label")
onready var font = label.get_font("font")


func _ready() -> void:
	$ScrollContainer.get_v_scrollbar().modulate = Color.transparent
	$ScrollContainer.get_v_scrollbar().rect_scale = Vector2.ZERO


func _process(_delta: float) -> void:
	var datetime = DateTime.now()
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
	font.size = 32 if get_viewport().size.x < 600 else 48 if get_viewport().size.x < 1000 else 64
