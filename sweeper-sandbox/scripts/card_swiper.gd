extends Control

signal decision_committed(direction, choice_data)
signal card_changed(card_index, is_decision_card)
signal drag_updated(direction, choice_data)
signal drag_ended()

const SWIPE_THRESHOLD = 80.0
const ROTATION_FACTOR = 0.0008

@onready var card_panel = $CardPanel
@onready var card_title = $CardPanel/VBoxContainer/TitleLabel
@onready var card_subtitle = $CardPanel/VBoxContainer/SubtitleLabel
@onready var card_desc = $CardPanel/VBoxContainer/DescLabel
@onready var choice_overlay = $CardPanel/ChoiceOverlay

# Preview Action Options & Affected Indicators List Container
@onready var actions_container = $CardPanel/VBoxContainer/ActionsContainer
@onready var actions_list = $CardPanel/VBoxContainer/ActionsContainer/ActionsList

# Navigation / PC Controls
@onready var pc_controls = $PCControls
@onready var btn_left = $PCControls/BtnLeft
@onready var btn_right = $PCControls/BtnRight
@onready var btn_up = $PCControls/BtnUp
@onready var btn_down = $PCControls/BtnDown
@onready var card_counter_label = $PCControls/CardCounterLabel

var current_block_data = {}
var all_cards = []
var current_card_index = 0
var is_decision_card = false

var is_dragging = false
var drag_start_pos = Vector2.ZERO
var initial_card_pos = Vector2.ZERO
var current_direction = ""

var typewriter_tween: Tween = null

func _ready():
	initial_card_pos = card_panel.position

	btn_left.pressed.connect(_on_btn_left_pressed)
	btn_right.pressed.connect(_on_btn_right_pressed)
	btn_up.pressed.connect(_on_btn_up_pressed)
	btn_down.pressed.connect(_on_btn_down_pressed)

func load_block_data(block: Dictionary, card_index: int = 0):
	current_block_data = block
	all_cards = []

	var stories = block.get("story_cards", [])
	for s in stories:
		var c = s.duplicate()
		c["type"] = "story"
		all_cards.append(c)

	var decision = block.get("decision_card", {}).duplicate()
	if not decision.is_empty():
		decision["type"] = "decision"
		all_cards.append(decision)

	current_card_index = clamp(card_index, 0, all_cards.size() - 1)
	display_current_card()

func display_current_card():
	if all_cards.is_empty():
		return

	if typewriter_tween and typewriter_tween.is_running():
		typewriter_tween.kill()

	var card = all_cards[current_card_index]
	is_decision_card = (card.get("type", "") == "decision")

	card_title.text = card.get("title", "")
	card_subtitle.text = card.get("location", "")

	var full_desc = card.get("description", "")

	card_counter_label.text = "Card " + str(current_card_index + 1) + " of " + str(all_cards.size())

	if is_decision_card:
		actions_container.visible = true
		card_desc.visible_ratio = 1.0
		card_desc.text = full_desc
		update_actions_list_preview(card.get("choices", {}))
	else:
		actions_container.visible = false
		# Animated fast typewriter effect for story cards!
		card_desc.text = full_desc
		card_desc.visible_ratio = 0.0

		# Typewriter duration relative to length, fast speed (0.015s per char, max 0.6s)
		var duration = clamp(full_desc.length() * 0.012, 0.2, 0.6)
		typewriter_tween = create_tween()
		typewriter_tween.tween_property(card_desc, "visible_ratio", 1.0, duration).set_trans(Tween.TRANS_LINEAR)

	update_button_visibility()
	reset_card_position_with_entrance()
	emit_signal("card_changed", current_card_index, is_decision_card)

func update_actions_list_preview(choices: Dictionary):
	for child in actions_list.get_children():
		child.queue_free()

	var active_mod = SaveManager.current_save_data.get("active_modifier", "")
	var dir_symbols = {"left": "◀ LEFT", "right": "RIGHT ▶", "up": "▲ UP", "down": "▼ DOWN"}

	for dir in ["left", "right", "up", "down"]:
		if choices.has(dir):
			var choice = choices[dir]
			var affected_indices = choice.get("affected", [])
			var deltas = choice.get("deltas", [0, 0, 0, 0, 0])
			var icons_info = ""

			for idx in affected_indices:
				var info = CardDatabase.INDICATORS.get(idx, {"icon_symbol": "?"})
				var sym = info.get("icon_symbol", "")
				var d = deltas[idx] if idx < deltas.size() else 0

				if active_mod in ["exact_insight", "timed_exact_insight"]:
					var val_str = ("+" if d >= 0 else "") + str(d)
					icons_info += sym + "(" + val_str + ") "
				elif active_mod in ["small_insight", "timed_small_insight"]:
					var range_str = "0"
					if d > 0:
						range_str = "+5..15" if d <= 15 else "+15..30"
					elif d < 0:
						range_str = "-5..15" if d >= -15 else "-15..30"
					icons_info += sym + "(" + range_str + ") "
				else:
					icons_info += sym + " "

			var lbl = Label.new()
			lbl.text = dir_symbols[dir] + ": " + choice.get("label", "") + " [" + icons_info.strip_edges() + "]"
			lbl.add_theme_font_size_override("font_size", 12)
			lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
			actions_list.add_child(lbl)

func update_button_visibility():
	if not is_decision_card:
		btn_left.visible = (current_card_index > 0)
		btn_left.text = "◀ PREV"
		btn_right.visible = true
		btn_right.text = "NEXT ▶"
		btn_up.visible = false
		btn_down.visible = false
	else:
		var choices = all_cards[current_card_index].get("choices", {})
		btn_left.visible = choices.has("left")
		btn_left.text = "◀ " + choices.get("left", {}).get("label", "LEFT")
		btn_right.visible = choices.has("right")
		btn_right.text = choices.get("right", {}).get("label", "RIGHT") + " ▶"
		btn_up.visible = choices.has("up")
		if btn_up.visible:
			btn_up.text = "▲ " + choices.get("up", {}).get("label", "UP")
		btn_down.visible = choices.has("down")
		if btn_down.visible:
			btn_down.text = "▼ " + choices.get("down", {}).get("label", "DOWN")

func _on_btn_left_pressed():
	if not is_decision_card:
		if current_card_index > 0:
			current_card_index -= 1
			display_current_card()
	else:
		commit_choice("left")

func _on_btn_right_pressed():
	if not is_decision_card:
		if current_card_index < all_cards.size() - 1:
			current_card_index += 1
			display_current_card()
	else:
		commit_choice("right")

func _on_btn_up_pressed():
	if is_decision_card:
		commit_choice("up")

func _on_btn_down_pressed():
	if is_decision_card:
		commit_choice("down")

func reset_card_position():
	card_panel.position = initial_card_pos
	card_panel.rotation = 0.0
	card_panel.scale = Vector2(1.0, 1.0)
	choice_overlay.text = ""
	current_direction = ""
	emit_signal("drag_ended")

func reset_card_position_with_entrance():
	card_panel.position = initial_card_pos + Vector2(0, -30)
	card_panel.rotation = 0.05
	card_panel.scale = Vector2(0.95, 0.95)
	choice_overlay.text = ""
	current_direction = ""
	emit_signal("drag_ended")

	var tween = create_tween().set_parallel(true)
	tween.tween_property(card_panel, "position", initial_card_pos, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card_panel, "rotation", 0.0, 0.35)
	tween.tween_property(card_panel, "scale", Vector2(1.0, 1.0), 0.35)

func _gui_input(event):
	if all_cards.is_empty():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_pos = event.position
			else:
				if is_dragging:
					is_dragging = false
					finish_drag()

	elif event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			drag_start_pos = event.position
		else:
			if is_dragging:
				is_dragging = false
				finish_drag()

	elif event is InputEventMouseMotion and is_dragging:
		var offset = event.position - drag_start_pos
		update_drag_position(offset)

	elif event is InputEventScreenDrag and is_dragging:
		var offset = event.position - drag_start_pos
		update_drag_position(offset)

func _unhandled_input(event):
	if all_cards.is_empty():
		return

	if event.is_action_pressed("ui_left"):
		_on_btn_left_pressed()
	elif event.is_action_pressed("ui_right"):
		_on_btn_right_pressed()
	elif event.is_action_pressed("ui_up") and is_decision_card:
		_on_btn_up_pressed()
	elif event.is_action_pressed("ui_down") and is_decision_card:
		_on_btn_down_pressed()

func update_drag_position(offset: Vector2):
	card_panel.position = initial_card_pos + offset
	card_panel.rotation = offset.x * ROTATION_FACTOR

	if offset.length() < 20.0:
		current_direction = ""
		choice_overlay.text = ""
		emit_signal("drag_ended")
		return

	if abs(offset.x) > abs(offset.y):
		current_direction = "right" if offset.x > 0 else "left"
	else:
		current_direction = "down" if offset.y > 0 else "up"

	if not is_decision_card:
		if current_direction in ["left", "right"]:
			choice_overlay.text = "READ PREV" if current_direction == "left" else "READ NEXT"
		else:
			current_direction = ""
			choice_overlay.text = ""
		return

	var choices = all_cards[current_card_index].get("choices", {})
	if choices.has(current_direction):
		var choice = choices[current_direction]
		choice_overlay.text = current_direction.to_upper() + ": " + choice.get("label", "")
		emit_signal("drag_updated", current_direction, choice)
	else:
		current_direction = ""
		choice_overlay.text = ""
		emit_signal("drag_ended")

func finish_drag():
	var offset = card_panel.position - initial_card_pos
	if offset.length() >= SWIPE_THRESHOLD and current_direction != "":
		if not is_decision_card:
			if current_direction == "right" and current_card_index < all_cards.size() - 1:
				current_card_index += 1
				display_current_card()
			elif current_direction == "left" and current_card_index > 0:
				current_card_index -= 1
				display_current_card()
			else:
				reset_card_position()
		else:
			commit_choice(current_direction)
	else:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(card_panel, "position", initial_card_pos, 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		tween.tween_property(card_panel, "rotation", 0.0, 0.3)
		choice_overlay.text = ""
		current_direction = ""
		emit_signal("drag_ended")

func commit_choice(direction: String):
	if not is_decision_card:
		return

	var choices = all_cards[current_card_index].get("choices", {})
	if choices.has(direction):
		var choice = choices[direction]

		var target_pos = initial_card_pos
		match direction:
			"left": target_pos = Vector2(-650, card_panel.position.y)
			"right": target_pos = Vector2(650, card_panel.position.y)
			"up": target_pos = Vector2(card_panel.position.x, -850)
			"down": target_pos = Vector2(card_panel.position.x, 850)

		var tween = create_tween().set_parallel(true)
		tween.tween_property(card_panel, "position", target_pos, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(card_panel, "rotation", (card_panel.rotation + 0.1) if direction != "left" else (card_panel.rotation - 0.1), 0.25)

		var seq_tween = create_tween()
		seq_tween.tween_interval(0.25)
		seq_tween.tween_callback(func():
			reset_card_position()
			emit_signal("decision_committed", direction, choice)
		)
