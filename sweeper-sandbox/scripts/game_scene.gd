extends Control

@onready var top_panel = $TopPanel
@onready var card_swiper = $CardSwiper
@onready var days_label = $Header/DaysLabel
@onready var menu_btn = $Header/MenuBtn

@onready var game_over_modal = $GameOverModal
@onready var game_over_reason = $GameOverModal/Panel/VBoxContainer/ReasonLabel
@onready var game_over_stats = $GameOverModal/Panel/VBoxContainer/StatsLabel
@onready var play_again_btn = $GameOverModal/Panel/VBoxContainer/PlayAgainBtn
@onready var main_menu_btn = $GameOverModal/Panel/VBoxContainer/MainMenuBtn

var days_survived = 0
var current_card = {}

func _ready():
	menu_btn.pressed.connect(_on_menu_pressed)
	play_again_btn.pressed.connect(_on_play_again_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)

	card_swiper.drag_updated.connect(_on_drag_updated)
	card_swiper.drag_ended.connect(_on_drag_ended)
	card_swiper.swipe_committed.connect(_on_swipe_committed)

	init_game()

func init_game():
	var save = SaveManager.current_save_data
	days_survived = save.get("days_survived", 0)
	var indicators = save.get("indicators", [50.0, 50.0, 50.0, 50.0])

	top_panel.set_indicators(indicators)
	update_days_label()

	load_next_card()

func update_days_label():
	days_label.text = "Decisions: " + str(days_survived)

func load_next_card():
	var used = SaveManager.current_save_data.get("used_card_ids", [])
	current_card = CardDatabase.get_random_card(used)
	card_swiper.set_card_data(current_card)

func _on_drag_updated(_direction: String, choice_data: Dictionary):
	var affected = choice_data.get("affected", [])
	top_panel.highlight_affected(affected)

func _on_drag_ended():
	top_panel.clear_highlights()

func _on_swipe_committed(_direction: String, choice_data: Dictionary):
	top_panel.clear_highlights()

	var deltas = choice_data.get("deltas", [0, 0, 0, 0])
	var result = top_panel.apply_deltas(deltas)

	days_survived += 1
	update_days_label()

	var used = SaveManager.current_save_data.get("used_card_ids", [])
	if not current_card.get("id", "") in used:
		used.append(current_card.get("id", ""))

	# Save current state
	SaveManager.current_save_data["days_survived"] = days_survived
	SaveManager.current_save_data["indicators"] = top_panel.values.duplicate()
	SaveManager.current_save_data["used_card_ids"] = used
	SaveManager.save_game()

	if result.get("game_over", false):
		handle_game_over(result)
	else:
		load_next_card()

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

	game_over_reason.text = reason_text
	game_over_stats.text = "You survived " + str(days_survived) + " decisions."

	# Clear active game save on loss
	SaveManager.clear_save()
	game_over_modal.visible = true

func _on_play_again_pressed():
	game_over_modal.visible = false
	SaveManager.start_new_game()
	init_game()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
