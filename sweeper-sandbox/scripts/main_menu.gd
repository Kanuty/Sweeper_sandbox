extends Control

@onready var new_game_btn = $MarginContainer/VBoxContainer/ButtonsContainer/NewGameBtn
@onready var continue_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ContinueBtn
@onready var shop_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ShopBtn
@onready var scores_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ScoresBtn
@onready var ach_btn = $MarginContainer/VBoxContainer/ButtonsContainer/AchBtn
@onready var how_to_play_btn = $MarginContainer/VBoxContainer/ButtonsContainer/HowToPlayBtn
@onready var exit_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ExitBtn

@onready var gold_label = $TopGoldBar/GoldLabel
@onready var shop_modal = $ShopModal
@onready var how_to_play_modal = $HowToPlayModal
@onready var close_how_to_play_btn = $HowToPlayModal/Panel/VBoxContainer/CloseBtn

# Name input modal
@onready var name_modal = $NameInputModal
@onready var name_edit = $NameInputModal/Panel/VBoxContainer/NameEdit
@onready var start_confirm_btn = $NameInputModal/Panel/VBoxContainer/StartConfirmBtn

# High Scores modal
@onready var scores_modal = $HighScoresModal
@onready var scores_list = $HighScoresModal/Panel/VBoxContainer/ScrollContainer/ScoresList
@onready var close_scores_btn = $HighScoresModal/Panel/VBoxContainer/CloseBtn

# Achievements modal
@onready var ach_modal = $AchievementsModal
@onready var ach_list = $AchievementsModal/Panel/VBoxContainer/ScrollContainer/AchList
@onready var close_ach_btn = $AchievementsModal/Panel/VBoxContainer/CloseBtn

func _ready():
	new_game_btn.pressed.connect(_on_new_game_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	shop_btn.pressed.connect(_on_shop_pressed)
	scores_btn.pressed.connect(_on_scores_pressed)
	ach_btn.pressed.connect(_on_ach_pressed)
	how_to_play_btn.pressed.connect(_on_how_to_play_pressed)
	close_how_to_play_btn.pressed.connect(_on_close_how_to_play_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

	start_confirm_btn.pressed.connect(_on_start_confirm_pressed)
	close_scores_btn.pressed.connect(func(): scores_modal.visible = false)
	close_ach_btn.pressed.connect(func(): ach_modal.visible = false)

	if shop_modal.has_signal("shop_closed"):
		shop_modal.shop_closed.connect(_on_shop_closed)

	update_ui_state()

func update_ui_state():
	var gold = SaveManager.current_save_data.get("gold_coins", 0)
	gold_label.text = "💰 Gold Balance: " + str(gold) + " Coins"

	if SaveManager.has_save():
		continue_btn.disabled = false
		continue_btn.text = "CONTINUE GAME"
	else:
		continue_btn.disabled = true
		continue_btn.text = "CONTINUE (No Saved Game)"

	shop_btn.disabled = false
	shop_btn.text = "SHOP"

func _on_new_game_pressed():
	name_modal.visible = true
	name_edit.text = SaveManager.current_save_data.get("player_name", "Hibernatus")

func _on_start_confirm_pressed():
	var actor_name = name_edit.text.strip_edges()
	if actor_name == "":
		actor_name = "Hibernatus"
	name_modal.visible = false
	SaveManager.start_new_game(actor_name)
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_shop_pressed():
	shop_modal.visible = true
	if shop_modal.has_method("update_shop_ui"):
		shop_modal.update_shop_ui()

func _on_shop_closed():
	update_ui_state()

func _on_scores_pressed():
	update_high_scores_ui()
	scores_modal.visible = true

func update_high_scores_ui():
	for child in scores_list.get_children():
		child.queue_free()

	var scores = SaveManager.current_save_data.get("high_scores", [])
	if scores.is_empty():
		var lbl = Label.new()
		lbl.text = "No high scores recorded yet. Complete a run to place on the leaderboard!"
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.add_theme_font_size_override("font_size", 12)
		scores_list.add_child(lbl)
		return

	var rank = 1
	for s in scores:
		var card = PanelContainer.new()
		var hbox = HBoxContainer.new()

		var rank_lbl = Label.new()
		rank_lbl.text = "#" + str(rank) + " " + s.get("name", "Hibernatus")
		rank_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rank_lbl.add_theme_font_size_override("font_size", 13)
		rank_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		hbox.add_child(rank_lbl)

		var stats_lbl = Label.new()
		stats_lbl.text = SaveManager.format_time_survived(s.get("hours", 0)) + " (" + str(s.get("points", 0)) + " Pts)"
		stats_lbl.add_theme_font_size_override("font_size", 12)
		stats_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
		hbox.add_child(stats_lbl)

		card.add_child(hbox)
		scores_list.add_child(card)
		rank += 1

func _on_ach_pressed():
	update_achievements_ui()
	ach_modal.visible = true

func update_achievements_ui():
	for child in ach_list.get_children():
		child.queue_free()

	var unlocked = SaveManager.current_save_data.get("unlocked_achievements", [])
	for key in SaveManager.ACHIEVEMENTS.keys():
		var ach = SaveManager.ACHIEVEMENTS[key]
		var is_unlocked = (key in unlocked)

		var card = PanelContainer.new()
		var vbox = VBoxContainer.new()

		var title_lbl = Label.new()
		title_lbl.text = ( "🏆 " if is_unlocked else "🔒 " ) + ach["title"]
		title_lbl.add_theme_font_size_override("font_size", 13)
		title_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4) if is_unlocked else Color(0.6, 0.6, 0.6))
		vbox.add_child(title_lbl)

		var desc_lbl = Label.new()
		desc_lbl.text = ach["desc"]
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 11)
		desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92) if is_unlocked else Color(0.5, 0.5, 0.5))
		vbox.add_child(desc_lbl)

		card.add_child(vbox)
		ach_list.add_child(card)

func _on_how_to_play_pressed():
	how_to_play_modal.visible = true

func _on_close_how_to_play_pressed():
	how_to_play_modal.visible = false

func _on_exit_pressed():
	get_tree().quit()
