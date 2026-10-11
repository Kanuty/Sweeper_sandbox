extends Control

@onready var top_panel = $TopPanel
@onready var card_swiper = $CardSwiper
@onready var days_label = $Header/DaysLabel
@onready var menu_btn = $Header/MenuBtn
@onready var shop_btn = $Header/ShopBtn

@onready var shop_modal = $ShopModal
@onready var game_over_modal = $GameOverModal
@onready var game_over_reason = $GameOverModal/Panel/VBoxContainer/ReasonLabel
@onready var game_over_stats = $GameOverModal/Panel/VBoxContainer/StatsLabel
@onready var gold_earned_label = $GameOverModal/Panel/VBoxContainer/GoldEarnedLabel
@onready var play_again_btn = $GameOverModal/Panel/VBoxContainer/PlayAgainBtn
@onready var main_menu_btn = $GameOverModal/Panel/VBoxContainer/MainMenuBtn

var hours_survived = 0
var current_block = {}

func _ready():
	menu_btn.pressed.connect(_on_menu_pressed)
	shop_btn.pressed.connect(_on_shop_pressed)
	play_again_btn.pressed.connect(_on_play_again_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)

	if shop_modal.has_signal("shop_closed"):
		shop_modal.shop_closed.connect(_on_shop_closed)

	card_swiper.card_changed.connect(_on_card_changed)
	card_swiper.drag_updated.connect(_on_drag_updated)
	card_swiper.drag_ended.connect(_on_drag_ended)
	card_swiper.decision_committed.connect(_on_decision_committed)

	init_game()

func init_game():
	var save = SaveManager.current_save_data
	hours_survived = save.get("hours_survived", 0)
	var indicators = save.get("indicators", [50.0, 50.0, 50.0, 50.0])
	var active_block_id = save.get("active_block_id", "")
	var active_card_idx = save.get("active_card_index", 0)

	top_panel.set_indicators(indicators)
	update_time_label()

	if active_block_id != "":
		current_block = CardDatabase.get_block_by_id(active_block_id)
		card_swiper.load_block_data(current_block, active_card_idx)
	else:
		load_next_block()

func update_time_label():
	var mod = SaveManager.current_save_data.get("active_modifier", "")
	var charges = SaveManager.current_save_data.get("modifier_block_charges", 0)
	var mod_str = ""
	if mod != "":
		if charges > 0:
			mod_str = " [" + mod.capitalize() + ": " + str(charges) + " left]"
		else:
			mod_str = " [" + mod.capitalize() + "]"

	days_label.text = "Time: " + SaveManager.format_time_survived(hours_survived) + mod_str

func load_next_block():
	var used = SaveManager.current_save_data.get("used_block_ids", [])
	current_block = CardDatabase.get_random_block(used)

	SaveManager.current_save_data["active_block_id"] = current_block.get("id", "")
	SaveManager.current_save_data["active_card_index"] = 0
	SaveManager.save_game()

	card_swiper.load_block_data(current_block, 0)

func _on_card_changed(card_index: int, _is_decision_card: bool):
	SaveManager.current_save_data["active_card_index"] = card_index
	SaveManager.save_game()

func _on_drag_updated(_direction: String, choice_data: Dictionary):
	var affected = choice_data.get("affected", [])
	var deltas = choice_data.get("deltas", [])
	var active_mod = SaveManager.current_save_data.get("active_modifier", "")
	top_panel.highlight_affected(affected, deltas, active_mod)

func _on_drag_ended():
	top_panel.clear_highlights()

func _on_decision_committed(_direction: String, choice_data: Dictionary):
	top_panel.clear_highlights()

	var deltas = choice_data.get("deltas", [0, 0, 0, 0])
	var result = top_panel.apply_deltas(deltas)

	var time_cost = current_block.get("time_cost_hours", 24)
	hours_survived += time_cost

	# Consume timed modifier charge
	SaveManager.consume_modifier_charge()
	update_time_label()

	var used = SaveManager.current_save_data.get("used_block_ids", [])
	if not current_block.get("id", "") in used:
		used.append(current_block.get("id", ""))

	SaveManager.current_save_data["hours_survived"] = hours_survived
	SaveManager.current_save_data["indicators"] = top_panel.values.duplicate()
	SaveManager.current_save_data["used_block_ids"] = used
	SaveManager.current_save_data["active_block_id"] = ""
	SaveManager.current_save_data["active_card_index"] = 0
	SaveManager.save_game()

	if result.get("game_over", false):
		handle_game_over(result)
	else:
		load_next_block()

func handle_game_over(result: Dictionary):
	var idx = result.get("failed_index", 0)
	var is_max = result.get("is_max", false)
	var ind_info = CardDatabase.INDICATORS.get(idx, {"name": "Resource"})
	var ind_name = ind_info.get("name", "Resource")

	var reason_text = ""
	if is_max:
		reason_text = "OVERFLOW! Your " + ind_name + " reached maximum capacity (100)!"
	else:
		reason_text = "DEPLETED! Your " + ind_name + " dropped to zero (0)!"

	# Gold award based on survival time (10 gold per day / 24 hours survived)
	var gold_earned = max(10, (hours_survived / 24) * 10 + 5)
	SaveManager.add_gold(gold_earned)

	game_over_reason.text = reason_text
	game_over_stats.text = "You survived for " + SaveManager.format_time_survived(hours_survived) + "!"
	gold_earned_label.text = "💰 Earned +" + str(gold_earned) + " Gold Coins!"

	SaveManager.clear_save()
	game_over_modal.visible = true

func _on_shop_pressed():
	shop_modal.visible = true
	if shop_modal.has_method("update_shop_ui"):
		shop_modal.update_shop_ui()

func _on_shop_closed():
	update_time_label()

func _on_play_again_pressed():
	game_over_modal.visible = false
	SaveManager.start_new_game()
	init_game()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
