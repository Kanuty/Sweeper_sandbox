extends Control

@onready var new_game_btn = $MarginContainer/VBoxContainer/ButtonsContainer/NewGameBtn
@onready var continue_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ContinueBtn
@onready var shop_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ShopBtn
@onready var how_to_play_btn = $MarginContainer/VBoxContainer/ButtonsContainer/HowToPlayBtn
@onready var exit_btn = $MarginContainer/VBoxContainer/ButtonsContainer/ExitBtn

@onready var how_to_play_modal = $HowToPlayModal
@onready var close_how_to_play_btn = $HowToPlayModal/Panel/VBoxContainer/CloseBtn

func _ready():
	# Connect signals
	new_game_btn.pressed.connect(_on_new_game_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	how_to_play_btn.pressed.connect(_on_how_to_play_pressed)
	close_how_to_play_btn.pressed.connect(_on_close_how_to_play_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

	update_buttons_state()

func update_buttons_state():
	# Continue button is enabled only if an active save exists
	if SaveManager.has_save():
		continue_btn.disabled = false
		continue_btn.text = "CONTINUE GAME"
	else:
		continue_btn.disabled = true
		continue_btn.text = "CONTINUE (No Saved Game)"

	# Shop button is turned off / locked
	shop_btn.disabled = true
	shop_btn.text = "SHOP (Locked)"

func _on_new_game_pressed():
	SaveManager.start_new_game()
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_how_to_play_pressed():
	how_to_play_modal.visible = true

func _on_close_how_to_play_pressed():
	how_to_play_modal.visible = false

func _on_exit_pressed():
	get_tree().quit()
