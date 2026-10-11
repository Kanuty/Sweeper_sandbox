extends Control

signal shop_closed()

@onready var gold_label = $Panel/VBoxContainer/Header/GoldLabel
@onready var items_container = $Panel/VBoxContainer/ScrollContainer/ItemsContainer
@onready var close_btn = $Panel/VBoxContainer/CloseBtn

func _ready():
	close_btn.pressed.connect(_on_close_pressed)
	update_shop_ui()

func update_shop_ui():
	var gold = SaveManager.current_save_data.get("gold_coins", 0)
	var active_mod = SaveManager.current_save_data.get("active_modifier", "")
	var charges = SaveManager.current_save_data.get("modifier_block_charges", 0)

	gold_label.text = "💰 Gold Balance: " + str(gold)

	for child in items_container.get_children():
		child.queue_free()

	for item in CardDatabase.shop_items:
		var item_id = item["id"]
		var item_name = item["name"]
		var desc = item["description"]
		var price = item["price"]
		var mod_type = item["type"]
		var item_charges = item["charges"]

		var card_panel = PanelContainer.new()
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 5)

		var title_lbl = Label.new()
		title_lbl.text = item_name
		title_lbl.add_theme_font_size_override("font_size", 16)
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		vbox.add_child(title_lbl)

		var desc_lbl = Label.new()
		desc_lbl.text = desc
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 13)
		desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
		vbox.add_child(desc_lbl)

		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(0, 40)

		if active_mod == mod_type and (item_charges == 0 or charges > 0):
			buy_btn.disabled = true
			if item_charges > 0:
				buy_btn.text = "EQUIPPED (" + str(charges) + " Blocks Left)"
			else:
				buy_btn.text = "EQUIPPED (Active)"
		elif gold < price:
			buy_btn.disabled = true
			buy_btn.text = "BUY (" + str(price) + " Gold) - Need More Gold"
		else:
			buy_btn.disabled = false
			buy_btn.text = "BUY & EQUIP (" + str(price) + " Gold)"
			buy_btn.pressed.connect(func(): buy_item(item))

		vbox.add_child(buy_btn)
		card_panel.add_child(vbox)
		items_container.add_child(card_panel)

func buy_item(item: Dictionary):
	var price = item["price"]
	var gold = SaveManager.current_save_data.get("gold_coins", 0)
	if gold >= price:
		SaveManager.add_gold(-price)
		SaveManager.set_modifier(item["type"], item["charges"])
		update_shop_ui()

func _on_close_pressed():
	visible = false
	emit_signal("shop_closed")
