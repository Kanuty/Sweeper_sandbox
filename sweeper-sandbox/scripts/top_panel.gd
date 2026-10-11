extends Control

signal indicator_failed(indicator_index, value, is_max)

@onready var indicator_bars = [
	$MarginContainer/HBoxContainer/Indicator0/VBoxContainer/ProgressBar,
	$MarginContainer/HBoxContainer/Indicator1/VBoxContainer/ProgressBar,
	$MarginContainer/HBoxContainer/Indicator2/VBoxContainer/ProgressBar,
	$MarginContainer/HBoxContainer/Indicator3/VBoxContainer/ProgressBar
]

@onready var indicator_labels = [
	$MarginContainer/HBoxContainer/Indicator0/VBoxContainer/ValueLabel,
	$MarginContainer/HBoxContainer/Indicator1/VBoxContainer/ValueLabel,
	$MarginContainer/HBoxContainer/Indicator2/VBoxContainer/ValueLabel,
	$MarginContainer/HBoxContainer/Indicator3/VBoxContainer/ValueLabel
]

@onready var affect_dots = [
	$MarginContainer/HBoxContainer/Indicator0/VBoxContainer/AffectDot,
	$MarginContainer/HBoxContainer/Indicator1/VBoxContainer/AffectDot,
	$MarginContainer/HBoxContainer/Indicator2/VBoxContainer/AffectDot,
	$MarginContainer/HBoxContainer/Indicator3/VBoxContainer/AffectDot
]

var values = [50.0, 50.0, 50.0, 50.0]

func set_indicators(new_values: Array):
	values = new_values.duplicate()
	update_display()

func update_display():
	for i in range(4):
		if i < indicator_bars.size() and i < values.size():
			var val = clamp(values[i], 0.0, 100.0)
			indicator_bars[i].value = val
			indicator_labels[i].text = str(int(round(val)))

func highlight_affected(affected_indices: Array):
	for i in range(4):
		if i < affect_dots.size():
			if i in affected_indices:
				affect_dots[i].modulate = Color(1.0, 0.85, 0.2, 1.0) # Active indicator dot
				affect_dots[i].visible = true
			else:
				affect_dots[i].visible = false

func clear_highlights():
	for dot in affect_dots:
		dot.visible = false

func apply_deltas(deltas: Array) -> Dictionary:
	var result = {
		"game_over": false,
		"failed_index": -1,
		"value": 0.0,
		"is_max": false
	}

	for i in range(min(4, deltas.size())):
		values[i] = clamp(values[i] + deltas[i], 0.0, 100.0)
		if values[i] <= 0.0:
			result["game_over"] = true
			result["failed_index"] = i
			result["value"] = values[i]
			result["is_max"] = false
		elif values[i] >= 100.0:
			result["game_over"] = true
			result["failed_index"] = i
			result["value"] = values[i]
			result["is_max"] = true

	update_display()
	return result
