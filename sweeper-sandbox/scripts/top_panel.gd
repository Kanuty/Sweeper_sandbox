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

@onready var indicator_panels = [
	$MarginContainer/HBoxContainer/Indicator0,
	$MarginContainer/HBoxContainer/Indicator1,
	$MarginContainer/HBoxContainer/Indicator2,
	$MarginContainer/HBoxContainer/Indicator3
]

@onready var shield_labels = [
	$MarginContainer/HBoxContainer/Indicator0/VBoxContainer/ShieldLabel,
	$MarginContainer/HBoxContainer/Indicator1/VBoxContainer/ShieldLabel,
	$MarginContainer/HBoxContainer/Indicator2/VBoxContainer/ShieldLabel,
	$MarginContainer/HBoxContainer/Indicator3/VBoxContainer/ShieldLabel
]

var values = [50.0, 50.0, 50.0, 50.0]

func set_indicators(new_values: Array):
	values = new_values.duplicate()
	update_display_immediate()
	update_protection_shields()

func update_protection_shields():
	var active_prots = SaveManager.current_save_data.get("active_protections", [])
	for i in range(4):
		if i < shield_labels.size():
			shield_labels[i].visible = false
			shield_labels[i].text = ""

	for p in active_prots:
		var ind = p.get("indicator", -1)
		if ind >= 0 and ind < shield_labels.size():
			var mode = p.get("mode", "")
			var ptype = p.get("type", "")
			var txt = "🛡️ " + mode.to_upper()
			if ptype == "big":
				txt = "🛡️ BIG SHIELD"
			shield_labels[ind].text = txt
			shield_labels[ind].visible = true

func update_display_immediate():
	for i in range(4):
		if i < indicator_bars.size() and i < values.size():
			var val = clamp(values[i], 0.0, 100.0)
			indicator_bars[i].value = val
			indicator_labels[i].text = str(int(round(val)))

func highlight_affected(affected_indices: Array, deltas: Array = [], insight_mode: String = ""):
	for i in range(4):
		if i < affect_dots.size():
			if i in affected_indices:
				var dot = affect_dots[i]
				dot.visible = true

				var d = 0
				if i < deltas.size():
					d = deltas[i]

				if insight_mode in ["exact_insight", "timed_exact_insight"]:
					dot.text = ("▲ +" if d >= 0 else "▼ ") + str(d)
					dot.modulate = Color(0.2, 1.0, 0.4) if d >= 0 else Color(0.3, 0.7, 1.0)
				elif insight_mode in ["small_insight", "timed_small_insight"]:
					var range_str = "0"
					if d > 0:
						range_str = "+5..15" if d <= 15 else "+15..30"
					elif d < 0:
						range_str = "-5..15" if d >= -15 else "-15..30"
					dot.text = "▲ " + range_str
					dot.modulate = Color(1.0, 0.85, 0.2)
				else:
					dot.text = "▲ AFFECTED"
					dot.modulate = Color(1.0, 0.85, 0.2, 1.0)
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
		"is_max": false,
		"protection_triggered": false
	}

	var active_prots = SaveManager.current_save_data.get("active_protections", []).duplicate()

	for i in range(min(4, deltas.size())):
		var old_val = values[i]
		var delta = deltas[i]
		var raw_new_val = old_val + delta
		var is_min_fail = (raw_new_val <= 0.0)
		var is_max_fail = (raw_new_val >= 100.0)

		var protected = false
		if is_min_fail or is_max_fail:
			# Check if active protection shields this indicator
			for p_idx in range(active_prots.size() - 1, -1, -1):
				var p = active_prots[p_idx]
				if p.get("indicator", -1) == i:
					var mode = p.get("mode", "")
					if (is_min_fail and (mode in ["min", "both"])) or (is_max_fail and (mode in ["max", "both"])):
						protected = true
						result["protection_triggered"] = true

						# Clamp safely to 15 or 85 instead of losing
						raw_new_val = 15.0 if is_min_fail else 85.0

						# Remove shield and trigger install cooldown (5 for small, 7 for big)
						var cd = 5 if p.get("type", "") == "small" else 7
						SaveManager.remove_protection_and_set_cooldown(p_idx, cd)
						break

		var new_val = clamp(raw_new_val, 0.0, 100.0)
		values[i] = new_val

		# Animate bar value over 0.5s
		var bar = indicator_bars[i]
		var lbl = indicator_labels[i]
		var panel = indicator_panels[i]

		var tween = create_tween().set_parallel(true)
		tween.tween_property(bar, "value", new_val, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		if delta > 0:
			var glow_tween = create_tween()
			glow_tween.tween_property(panel, "modulate", Color(1.5, 1.4, 0.4, 1.0), 0.15)
			glow_tween.tween_property(panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.35)
		elif delta < 0:
			var glow_tween = create_tween()
			glow_tween.tween_property(panel, "modulate", Color(0.4, 0.8, 1.8, 1.0), 0.15)
			glow_tween.tween_property(panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.35)

		lbl.text = str(int(round(new_val)))

		if not protected:
			if new_val <= 0.0:
				result["game_over"] = true
				result["failed_index"] = i
				result["value"] = new_val
				result["is_max"] = false
			elif new_val >= 100.0:
				result["game_over"] = true
				result["failed_index"] = i
				result["value"] = new_val
				result["is_max"] = true

	update_protection_shields()
	return result
