extends Control

@onready var new_game_btn = $MarginContainer/VBoxContainer/ButtonsContainer/NewGameBtn
@onready var continue_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ContinueBtn
@onready var shop_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ShopBtn
@onready var how_to_play_btn = $MarginContainer/VBoxContainer/ButtonsContainer/HowToPlayBtn
@onready var exit_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ExitBtn

@onready var gold_label = $MarginContainer/VBoxContainer/HeaderContainer/GoldLabel
@onready var shop_modal = $ShopModal
@onready var how_to_play_modal = $HowToPlayModal
@onready var close_how_to_play_btn = $HowToPlayModal/Panel/VBoxContainer/CloseBtn

func _ready():
	new_game_btn.pressed.connect(_on_new_game_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	shop_btn.pressed.connect(_on_shop_pressed)
	how_to_play_btn.pressed.connect(_on_how_to_play_pressed)
	close_how_to_play_btn.pressed.connect(_on_close_how_to_play_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

	if shop_modal.has_signal("shop_closed"):
		shop_modal.shop_closed.connect(_on_shop_closed)

	update_ui_state()

func update_ui_state():
	var gold = SaveManager.current_save_data.get("gold_coins", 100)
	gold_label.text = "💰 Gold Balance: " + str(gold)

	if SaveManager.has_save():
		continue_btn.disabled = false
		continue_btn.text = "CONTINUE GAME"
	else:
		continue_btn.disabled = true
		continue_btn.text = "CONTINUE (No Saved Game)"

	shop_btn.disabled = false
	shop_btn.text = "INSIGHT SHOP"

func _on_new_game_pressed():
	SaveManager.start_new_game()
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

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
