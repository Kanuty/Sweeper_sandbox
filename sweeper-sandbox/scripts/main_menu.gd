extends Control

@onready var new_game_btn = $MarginContainer/VBoxContainer/ButtonsContainer/NewGameBtn
@onready var continue_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ContinueBtn
@onready var leaderboard_btn = $MarginContainer/VBoxContainer/ButtonsContainer/LeaderboardBtn
@onready var achievements_btn = $MarginContainer/VBoxContainer/ButtonsContainer/AchievementsBtn
@onready var shop_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ShopBtn
@onready var how_to_play_btn = $MarginContainer/VBoxContainer/ButtonsContainer/HowToPlayBtn
@onready var exit_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ExitBtn

@onready var gold_label = $MarginContainer/VBoxContainer/HeaderContainer/GoldLabel
@onready var shop_modal = $ShopModal
@onready var how_to_play_modal = $HowToPlayModal
@onready var close_how_to_play_btn = $HowToPlayModal/Panel/VBoxContainer/CloseBtn

# Player Naming Modal
@onready var name_modal = $NameModal
@onready var name_input = $NameModal/Panel/VBoxContainer/NameLineEdit
@onready var start_named_game_btn = $NameModal/Panel/VBoxContainer/StartGameBtn
@onready var cancel_name_btn = $NameModal/Panel/VBoxContainer/CancelBtn

# Leaderboard Modal
@onready var leaderboard_modal = $LeaderboardModal
@onready var leaderboard_list = $LeaderboardModal/Panel/VBoxContainer/ScrollContainer/ScoresList
@onready var close_leaderboard_btn = $LeaderboardModal/Panel/VBoxContainer/CloseBtn

# Achievements Modal
@onready var achievements_modal = $AchievementsModal
@onready var achievements_list = $AchievementsModal/Panel/VBoxContainer/ScrollContainer/AchsList
@onready var close_achievements_btn = $AchievementsModal/Panel/VBoxContainer/CloseBtn

func _ready():
	new_game_btn.pressed.connect(_on_new_game_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	leaderboard_btn.pressed.connect(_on_leaderboard_pressed)
	achievements_btn.pressed.connect(_on_achievements_pressed)
	shop_btn.pressed.connect(_on_shop_pressed)
	how_to_play_btn.pressed.connect(_on_how_to_play_pressed)
	close_how_to_play_btn.pressed.connect(_on_close_how_to_play_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

	start_named_game_btn.pressed.connect(_on_start_named_game_pressed)
	cancel_name_btn.pressed.connect(_on_cancel_name_pressed)

	close_leaderboard_btn.pressed.connect(func(): leaderboard_modal.visible = false)
	close_achievements_btn.pressed.connect(func(): achievements_modal.visible = false)

	if shop_modal.has_signal("shop_closed"):
		shop_modal.shop_closed.connect(_on_shop_closed)

	update_ui_state()

func update_ui_state():
	var gold = SaveManager.current_save_data.get("gold_coins", 100)
	gold_label.text = "💰 Scrap Gold: " + str(gold)

	if SaveManager.has_save():
		continue_btn.disabled = false
		continue_btn.text = "CONTINUE GAME"
	else:
		continue_btn.disabled = true
		continue_btn.text = "CONTINUE (No Saved Game)"

	shop_btn.disabled = false
	shop_btn.text = "INSIGHT SHOP"

func _on_new_game_pressed():
	name_input.text = SaveManager.current_save_data.get("player_name", "Hibernatus-09")
	name_modal.visible = true

func _on_start_named_game_pressed():
	var p_name = name_input.text.strip_edges()
	if p_name == "":
		p_name = "Hibernatus-09"
	SaveManager.start_new_game(p_name)
	name_modal.visible = false
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_cancel_name_pressed():
	name_modal.visible = false

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_leaderboard_pressed():
	for child in leaderboard_list.get_children():
		child.queue_free()

	var scores = SaveManager.current_save_data.get("high_scores", [])
	if scores.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "No recorded scores yet! Play a game to record your survival legend."
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		leaderboard_list.add_child(empty_lbl)
	else:
		var rank = 1
		for s in scores:
			var panel = PanelContainer.new()
			var hbox = HBoxContainer.new()

			var rank_lbl = Label.new()
			rank_lbl.text = "#" + str(rank) + " " + s.get("name", "Hibernatus")
			rank_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			rank_lbl.add_theme_font_size_override("font_size", 14)
			hbox.add_child(rank_lbl)

			var stats_lbl = Label.new()
			stats_lbl.text = str(s.get("points", 0)) + " Pts (" + SaveManager.format_time_survived(s.get("hours", 0)) + ")"
			stats_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
			stats_lbl.add_theme_font_size_override("font_size", 13)
			hbox.add_child(stats_lbl)

			panel.add_child(hbox)
			leaderboard_list.add_child(panel)
			rank += 1

	leaderboard_modal.visible = true

func _on_achievements_pressed():
	for child in achievements_list.get_children():
		child.queue_free()

	var unlocked = SaveManager.current_save_data.get("unlocked_achievements", [])
	for ach_id in SaveManager.ACHIEVEMENTS_LIST:
		var ach = SaveManager.ACHIEVEMENTS_LIST[ach_id]
		var is_unlocked = ach_id in unlocked

		var panel = PanelContainer.new()
		var vbox = VBoxContainer.new()

		var title = Label.new()
		title.text = ("🏆 " if is_unlocked else "🔒 ") + ach["title"]
		title.add_theme_font_size_override("font_size", 14)
		title.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4) if is_unlocked else Color(0.6, 0.6, 0.6))
		vbox.add_child(title)

		var desc = Label.new()
		desc.text = ach["desc"]
		desc.add_theme_font_size_override("font_size", 12)
		desc.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
		vbox.add_child(desc)

		panel.add_child(vbox)
		achievements_list.add_child(panel)

	achievements_modal.visible = true

func _on_shop_pressed():
	shop_modal.visible = true
	if shop_modal.has_method("update_shop_ui"):
		shop_modal.update_shop_ui()

func _on_shop_closed():
	update_ui_state()

func _on_how_to_play_pressed():
	how_to_play_modal.visible = true

func _on_close_how_to_play_pressed():
	how_to_play_modal.visible = false

func _on_exit_pressed():
	get_tree().quit()
