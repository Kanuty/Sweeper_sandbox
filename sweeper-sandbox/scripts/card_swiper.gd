extends Control

signal decision_committed(direction, choice_data)
signal card_changed(index, is_decision_card)

@onready var card_panel = $CardPanel
@onready var card_title = $CardPanel/VBoxContainer/TitleLabel
@onready var card_subtitle = $CardPanel/VBoxContainer/SubtitleLabel
@onready var card_desc = $CardPanel/VBoxContainer/DescLabel
@onready var actions_container = $CardPanel/VBoxContainer/ActionsContainer
@onready var choices_list = $CardPanel/VBoxContainer/ActionsContainer/ChoicesList

@onready var pc_controls = $PCControls
@onready var btn_prev = $PCControls/BtnPrev
@onready var btn_next = $PCControls/BtnNext
@onready var card_counter_label = $PCControls/CardCounterLabel

var current_block_data = {}
var all_cards = []
var current_card_index = 0
var is_decision_card = false

var typewriter_tween: Tween = null

func _ready():
	if btn_prev:
		btn_prev.pressed.connect(_on_btn_prev_pressed)
	if btn_next:
		btn_next.pressed.connect(_on_btn_next_pressed)

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

	current_card_index = clamp(card_index, 0, max(0, all_cards.size() - 1))
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
	card_counter_label.text = "LOG ENTRY " + str(current_card_index + 1) + " OF " + str(all_cards.size())

	if is_decision_card:
		actions_container.visible = true
		card_desc.visible_ratio = 1.0
		card_desc.text = full_desc
		update_decision_options(card.get("choices", {}))
	else:
		actions_container.visible = false
		card_desc.text = full_desc
		card_desc.visible_ratio = 0.0

		var duration = clamp(full_desc.length() * 0.012, 0.2, 0.6)
		typewriter_tween = create_tween()
		typewriter_tween.tween_property(card_desc, "visible_ratio", 1.0, duration).set_trans(Tween.TRANS_LINEAR)

	update_navigation_controls()
	reset_card_appearance()
	emit_signal("card_changed", current_card_index, is_decision_card)

func update_decision_options(choices: Dictionary):
	for child in choices_list.get_children():
		child.queue_free()

	var active_mod = SaveManager.current_save_data.get("active_modifier", "")

	# Render vertical choice buttons for available decision options
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

			var btn = Button.new()
			var full_btn_text = choice.get("label", "").to_upper()
			if not icons_info.strip_edges().is_empty():
				full_btn_text += "  [" + icons_info.strip_edges() + "]"

			btn.text = full_btn_text
			btn.custom_minimum_size = Vector2(0, 42)
			btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			btn.add_theme_font_size_override("font_size", 12)
			btn.add_theme_color_override("font_color", Color(0.12, 0.08, 0.04, 1))

			var normal_style = StyleBoxTexture.new()
			normal_style.texture = load("res://assets/ui/button_orange.png")
			normal_style.texture_margin_left = 10
			normal_style.texture_margin_top = 10
			normal_style.texture_margin_right = 10
			normal_style.texture_margin_bottom = 10
			normal_style.content_margin_left = 8
			normal_style.content_margin_right = 8
			btn.add_theme_stylebox_override("normal", normal_style)
			btn.add_theme_stylebox_override("hover", normal_style)

			var pressed_style = normal_style.duplicate()
			pressed_style.modulate_color = Color(0.8, 0.8, 0.8, 1)
			btn.add_theme_stylebox_override("pressed", pressed_style)

			var dir_capture = dir
			var choice_capture = choice
			btn.pressed.connect(func(): commit_choice(dir_capture, choice_capture))

			choices_list.add_child(btn)

func update_navigation_controls():
	if not is_decision_card:
		btn_prev.visible = (current_card_index > 0)
		btn_next.visible = (current_card_index < all_cards.size() - 1)
	else:
		# On decision card, story navigation buttons are hidden to focus on choice buttons
		btn_prev.visible = (current_card_index > 0)
		btn_next.visible = false

func _on_btn_prev_pressed():
	if current_card_index > 0:
		current_card_index -= 1
		display_current_card()

func _on_btn_next_pressed():
	if current_card_index < all_cards.size() - 1:
		current_card_index += 1
		display_current_card()

func reset_card_appearance():
	card_panel.position = Vector2(0, 0)
	card_panel.rotation = 0.0
	card_panel.scale = Vector2(1.0, 1.0)
	card_panel.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(card_panel, "modulate:a", 1.0, 0.2)

func commit_choice(direction: String, choice_data: Dictionary):
	if not is_decision_card:
		return

	var tween = create_tween()
	tween.tween_property(card_panel, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		reset_card_appearance()
		emit_signal("decision_committed", direction, choice_data)
	)

func _unhandled_input(event):
	if all_cards.is_empty():
		return

	if event.is_action_pressed("ui_left") and btn_prev.visible:
		_on_btn_prev_pressed()
	elif event.is_action_pressed("ui_right") and btn_next.visible:
		_on_btn_next_pressed()
