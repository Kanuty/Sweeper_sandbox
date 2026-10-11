extends Control

signal shop_closed()

@onready var gold_label = $Panel/VBoxContainer/Header/GoldLabel
@onready var items_container = $Panel/VBoxContainer/ScrollContainer/ItemsContainer
@onready var close_btn = $Panel/VBoxContainer/CloseBtn

var inset_style: StyleBoxTexture
var btn_orange_style: StyleBoxTexture
var btn_orange_pressed: StyleBoxTexture

func _ready():
	inset_style = StyleBoxTexture.new()
	inset_style.texture = load("res://assets/ui/panel_inset_well.png")
	inset_style.texture_margin_left = 12
	inset_style.texture_margin_top = 12
	inset_style.texture_margin_right = 12
	inset_style.texture_margin_bottom = 12
	inset_style.content_margin_left = 10
	inset_style.content_margin_top = 10
	inset_style.content_margin_right = 10
	inset_style.content_margin_bottom = 10

	btn_orange_style = StyleBoxTexture.new()
	btn_orange_style.texture = load("res://assets/ui/button_orange.png")
	btn_orange_style.texture_margin_left = 10
	btn_orange_style.texture_margin_top = 10
	btn_orange_style.texture_margin_right = 10
	btn_orange_style.texture_margin_bottom = 10

	btn_orange_pressed = StyleBoxTexture.new()
	btn_orange_pressed.texture = load("res://assets/ui/button_orange.png")
	btn_orange_pressed.texture_margin_left = 10
	btn_orange_pressed.texture_margin_top = 10
	btn_orange_pressed.texture_margin_right = 10
	btn_orange_pressed.texture_margin_bottom = 10
	btn_orange_pressed.modulate_color = Color(0.8, 0.8, 0.8)

	close_btn.pressed.connect(_on_close_pressed)
	update_shop_ui()

func update_shop_ui():
	var gold = SaveManager.current_save_data.get("gold_coins", 0)
	var active_mod = SaveManager.current_save_data.get("active_modifier", "")
	var inv = SaveManager.current_save_data.get("inventory", [])
	var charges = SaveManager.current_save_data.get("modifier_block_charges", 0)

	gold_label.text = "💰 Scrap Gold: " + str(gold)

	for child in items_container.get_children():
		child.queue_free()

	for item in CardDatabase.shop_items:
		var item_id = item["id"]
		var item_name = item["name"]
		var desc = item["description"]
		var price = item["price"]
		var category = item.get("category", "insight")
		var is_locked = item.get("locked", false)

		var card_panel = PanelContainer.new()
		card_panel.add_theme_stylebox_override("panel", inset_style)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)

		var title_lbl = Label.new()
		title_lbl.text = item_name
		title_lbl.add_theme_font_size_override("font_size", 14)
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if category == "insight" else Color(0.3, 0.9, 1.0))
		vbox.add_child(title_lbl)

		var desc_lbl = Label.new()
		desc_lbl.text = desc
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 12)
		desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
		vbox.add_child(desc_lbl)

		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(0, 36)
		buy_btn.add_theme_stylebox_override("normal", btn_orange_style)
		buy_btn.add_theme_stylebox_override("pressed", btn_orange_pressed)
		buy_btn.add_theme_color_override("font_color", Color(0.12, 0.08, 0.04))

		if is_locked:
			buy_btn.disabled = true
			buy_btn.text = "LOCKED / UNRELEASED"
		elif category == "insight":
			var mod_type = item["type"]
			var item_charges = item["charges"]
			if active_mod == mod_type and (item_charges == 0 or charges > 0):
				buy_btn.disabled = true
				if item_charges > 0:
					buy_btn.text = "EQUIPPED (" + str(charges) + " Blocks Left)"
				else:
					buy_btn.text = "EQUIPPED (Active)"
			elif gold < price:
				buy_btn.disabled = true
				buy_btn.text = "BUY (" + str(price) + " Gold) - Need Gold"
			else:
				buy_btn.disabled = false
				buy_btn.text = "BUY & EQUIP (" + str(price) + " Gold)"
				buy_btn.pressed.connect(func():
					if SaveManager.current_save_data.get("gold_coins", 0) >= price:
						SaveManager.add_gold(-price)
						SaveManager.set_modifier(mod_type, item_charges)
						update_shop_ui()
				)
		elif category == "protection":
			if item_id in inv:
				buy_btn.disabled = true
				buy_btn.text = "PURCHASED (In Inventory)"
			elif gold < price:
				buy_btn.disabled = true
				buy_btn.text = "BUY (" + str(price) + " Gold) - Need Gold"
			else:
				buy_btn.disabled = false
				buy_btn.text = "BUY TO INVENTORY (" + str(price) + " Gold)"
				buy_btn.pressed.connect(func():
					if SaveManager.current_save_data.get("gold_coins", 0) >= price:
						SaveManager.add_gold(-price)
						SaveManager.add_to_inventory(item_id)
						update_shop_ui()
				)

		vbox.add_child(buy_btn)
		card_panel.add_child(vbox)
		items_container.add_child(card_panel)

func _on_close_pressed():
	visible = false
	emit_signal("shop_closed")
