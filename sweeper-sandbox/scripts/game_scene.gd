extends Control

@onready var top_panel = $TopPanel
@onready var card_swiper = $CardSwiper
@onready var days_label = $Header/DaysLabel
@onready var points_label = $Header/PointsLabel
@onready var menu_btn = $Header/MenuBtn
@onready var shop_btn = $Header/ShopBtn

@onready var shop_modal = $ShopModal
@onready var pause_modal = $PauseEquipmentModal
@onready var close_pause_btn = $PauseEquipmentModal/Panel/VBoxContainer/CloseBtn
@onready var inventory_list = $PauseEquipmentModal/Panel/VBoxContainer/ScrollContainer/InventoryList
@onready var main_menu_from_pause_btn = $PauseEquipmentModal/Panel/VBoxContainer/MainMenuBtn

@onready var game_over_modal = $GameOverModal
@onready var game_over_reason = $GameOverModal/Panel/VBoxContainer/ReasonLabel
@onready var game_over_stats = $GameOverModal/Panel/VBoxContainer/StatsLabel
@onready var gold_earned_label = $GameOverModal/Panel/VBoxContainer/GoldEarnedLabel
@onready var play_again_btn = $GameOverModal/Panel/VBoxContainer/PlayAgainBtn
@onready var main_menu_btn = $GameOverModal/Panel/VBoxContainer/MainMenuBtn

# Score popup label
@onready var score_popup = $ScorePopup

var hours_survived = 0
var survival_points = 0
var current_block = {}
var is_in_doom_history = false
var pending_game_over_result = {}

# Pools of 2-3 slide bad end epilogues for all failure conditions
const BAD_END_EPILOGUES = {
	"energy_0": [ # Total Exhaustion
		[
			{
				"title": "EPILOGUE I: Total Exhaustion",
				"location": "The Unforgiving Trail",
				"description": "Your body has been running on its last reserves for far too long. Your muscles finally refuse to cooperate, your legs give way, and you collapse into the ash."
			},
			{
				"title": "EPILOGUE II: Silent Slumber",
				"location": "Scorched Wilderness",
				"description": "The cold wind sweeps across your prone body. Heavy eyelids fall shut as consciousness slips away. This time, you don't have enough energy to wake up."
			}
		],
		[
			{
				"title": "EPILOGUE I: Muscle Collapse",
				"location": "Ruin Outer Perimeter",
				"description": "Tremors shake your limbs as adrenaline completely vanishes. Every breath becomes an unbearable ordeal."
			},
			{
				"title": "EPILOGUE II: Fading Pulse",
				"location": "Dust Basin",
				"description": "Your strength ebbs away completely. You close your eyes for a quick rest, but the wasteland claims you in eternal slumber."
			}
		]
	],
	"energy_100": [ # Cardiac Overload
		[
			{
				"title": "EPILOGUE I: Cardiac Overload",
				"location": "High-Stress Zone",
				"description": "Too much stimulation, too much adrenaline, and nowhere for all that energy to go. Your pulse hammers inside your skull like a war drum."
			},
			{
				"title": "EPILOGUE II: Sudden Halt",
				"location": "Ashen Plateau",
				"description": "Your heart starts racing uncontrollably, fluttering violently against your ribs. A moment later, it stops altogether."
			}
		]
	],
	"food_0": [ # Starvation
		[
			{
				"title": "EPILOGUE I: Starvation",
				"location": "Barren Scraplands",
				"description": "You've pushed your hunger aside one too many times. Your body has consumed its last reserves, and your organs begin shutting down."
			},
			{
				"title": "EPILOGUE II: Final Silence",
				"location": "The Scorched Trail",
				"description": "Your stomach finally stops complaining. So does everything else. You collapse silently into the dry soil."
			}
		]
	],
	"food_100": [ # Digestive Catastrophe
		[
			{
				"title": "EPILOGUE I: Digestive Catastrophe",
				"location": "Salvage Camp Shelter",
				"description": "Your digestive system wasn't prepared for this much food in such a short time. Your stomach swells in agony as fever grips your limbs."
			},
			{
				"title": "EPILOGUE II: Fatal Rupture",
				"location": "Camp Interior",
				"description": "The pain becomes unbearable, and something inside you ruptures. Apparently, there is such a thing as too much dinner."
			}
		]
	],
	"equipment_0": [ # Improvisation Failed
		[
			{
				"title": "EPILOGUE I: Improvisation Failed",
				"location": "Ruined Outpost Gate",
				"description": "You've been improvising without proper tools for too long. Your makeshift survival gear crumbles into useless fragments."
			},
			{
				"title": "EPILOGUE II: Bare Hands Failure",
				"location": "Outer Perimeter",
				"description": "One final attempt to fix something with your bare hands goes terribly wrong. Turns out some jobs really do require equipment."
			}
		]
	],
	"equipment_100": [ # Crushed by Possessions
		[
			{
				"title": "EPILOGUE I: Crushed by Possessions",
				"location": "Narrow Mountain Pass",
				"description": "You've been carrying far more than your body can handle. Your knees buckle under the towering weight of salvaged metal."
			},
			{
				"title": "EPILOGUE II: Trapped Load",
				"location": "Ravine Floor",
				"description": "Your overloaded backpack drags you down, landing you in a position you can't escape from. All those useful tools, and not one can help you now."
			}
		]
	],
	"sanity_0": [ # Complete Breakdown
		[
			{
				"title": "EPILOGUE I: Complete Breakdown",
				"location": "Echoing Ruins",
				"description": "Too many horrors, too little rest, and far too many voices in your head. You can no longer distinguish reality from hallucination."
			},
			{
				"title": "EPILOGUE II: Lost Instincts",
				"location": "The Foggy Chasm",
				"description": "Your survival instincts disappear along with your last coherent thought. You step into the abyss, smiling at shadows."
			}
		]
	],
	"sanity_100": [ # Analysis Paralysis
		[
			{
				"title": "EPILOGUE I: Analysis Paralysis",
				"location": "Crossroads of Ashes",
				"description": "You've become obsessed with making the perfect decision. Every movement requires calculation, every risk demands another assessment."
			},
			{
				"title": "EPILOGUE II: Endless Deliberation",
				"location": "Frozen Trail",
				"description": "Eventually, you stop acting altogether, locked in an infinite loop of logic. Your body doesn't survive the endless deliberation."
			}
		]
	],
	"radiation_100": [ # Acute Radiation Sickness / Cellular Collapse
		[
			{
				"title": "EPILOGUE I: Acute Radiation Sickness",
				"location": "Radioactive Crater",
				"description": "You've absorbed far more radiation than any human body can withstand. Severe nausea turns into violent vomiting as skin begins to blister."
			},
			{
				"title": "EPILOGUE II: Organ Failure",
				"location": "Glow Horizon",
				"description": "Your organs progressively fail under intense irradiation. Your body has reached its absolute limit."
			}
		],
		[
			{
				"title": "EPILOGUE I: Cellular Collapse",
				"location": "Hot Zone Perimeter",
				"description": "Radiation has damaged your cells faster than your body can repair them. Internal bleeding begins as your bone marrow fails."
			},
			{
				"title": "EPILOGUE II: Immune Collapse",
				"location": "Scorched Ridge",
				"description": "Your immune system collapses entirely. You survived the apocalypse, but not what it left behind."
			}
		]
	]
}

func _ready():
	menu_btn.pressed.connect(_on_menu_pressed)
	shop_btn.pressed.connect(_on_shop_pressed)
	close_pause_btn.pressed.connect(_on_close_pause_pressed)
	main_menu_from_pause_btn.pressed.connect(_on_main_menu_pressed)

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
	survival_points = save.get("survival_points", 0)
	var indicators = save.get("indicators", SaveManager.DEFAULT_INDICATORS)
	var active_block_id = save.get("active_block_id", "")
	var active_card_idx = save.get("active_card_index", 0)

	top_panel.set_indicators(indicators)
	update_time_and_points_label()

	if active_block_id != "":
		current_block = CardDatabase.get_block_by_id(active_block_id)
		card_swiper.load_block_data(current_block, active_card_idx)
	else:
		load_next_block()

func update_time_and_points_label():
	var mod = SaveManager.current_save_data.get("active_modifier", "")
	var charges = SaveManager.current_save_data.get("modifier_block_charges", 0)
	var cd = SaveManager.current_save_data.get("install_cooldown", 0)

	var status_str = ""
	if cd > 0:
		status_str += " [Install CD: " + str(cd) + "]"
	if mod != "":
		status_str += " [" + mod.capitalize() + ((":" + str(charges)) if charges > 0 else "") + "]"

	days_label.text = SaveManager.format_time_survived(hours_survived) + status_str
	points_label.text = "PTS: " + str(survival_points)

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
	if is_in_doom_history:
		return
	var affected = choice_data.get("affected", [])
	var deltas = choice_data.get("deltas", [])
	var active_mod = SaveManager.current_save_data.get("active_modifier", "")
	top_panel.highlight_affected(affected, deltas, active_mod)

func _on_drag_ended():
	top_panel.clear_highlights()

func _on_decision_committed(_direction: String, choice_data: Dictionary):
	top_panel.clear_highlights()

	if is_in_doom_history:
		# Player finished reading multi-slide bad end epilogue cards!
		is_in_doom_history = false
		show_final_game_over_popup(pending_game_over_result)
		return

	var deltas = choice_data.get("deltas", [0, 0, 0, 0, 0])
	var result = top_panel.apply_deltas(deltas)

	var time_cost = current_block.get("time_cost_hours", 24)
	hours_survived += time_cost

	var pts_earned = current_block.get("reward_points", 25)
	survival_points += pts_earned

	show_points_popup(pts_earned)

	# Check time survived achievements
	SaveManager.check_time_achievements(hours_survived)

	SaveManager.consume_modifier_charge()
	SaveManager.add_survival_points(pts_earned)
	update_time_and_points_label()

	var used = SaveManager.current_save_data.get("used_block_ids", [])
	var block_id = current_block.get("id", "")
	var is_generic = current_block.get("is_generic", false)

	if not is_generic and not block_id in used:
		used.append(block_id)

	SaveManager.current_save_data["hours_survived"] = hours_survived
	SaveManager.current_save_data["indicators"] = top_panel.values.duplicate()
	SaveManager.current_save_data["used_block_ids"] = used
	SaveManager.current_save_data["active_block_id"] = ""
	SaveManager.current_save_data["active_card_index"] = 0
	SaveManager.save_game()

	if result.get("game_over", false):
		start_doom_history_sequence(result)
	else:
		load_next_block()

func show_points_popup(pts: int):
	score_popup.text = "+" + str(pts) + " Survival Points!"
	score_popup.position = Vector2(100, 180)
	score_popup.modulate = Color(1.0, 0.85, 0.2, 1.0)
	score_popup.visible = true

	var tween = create_tween().set_parallel(true)
	tween.tween_property(score_popup, "position", Vector2(100, 140), 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(score_popup, "modulate", Color(1.0, 0.85, 0.2, 0.0), 0.8)

func start_doom_history_sequence(result: Dictionary):
	is_in_doom_history = true
	pending_game_over_result = result

	# Unlock achievement if losing with insight active
	var mod = SaveManager.current_save_data.get("active_modifier", "")
	if mod != "":
		SaveManager.unlock_achievement("lost_with_insight")

	var idx = result.get("failed_index", 0)
	var is_max = result.get("is_max", false)

	var pool_key = "energy_0"
	if idx == 0:
		pool_key = "energy_100" if is_max else "energy_0"
	elif idx == 1:
		pool_key = "food_100" if is_max else "food_0"
	elif idx == 2:
		pool_key = "equipment_100" if is_max else "equipment_0"
	elif idx == 3:
		pool_key = "sanity_100" if is_max else "sanity_0"
	else:
		pool_key = "radiation_100"

	var available_epilogues = BAD_END_EPILOGUES.get(pool_key, BAD_END_EPILOGUES["energy_0"])
	var chosen_epilogue = available_epilogues[randi() % available_epilogues.size()]

	var story_cards = []
	for i in range(chosen_epilogue.size() - 1):
		story_cards.append(chosen_epilogue[i])

	var last_card = chosen_epilogue[chosen_epilogue.size() - 1]

	var doom_block = {
		"id": "doom_block",
		"time_cost_hours": 0,
		"reward_points": 0,
		"story_cards": story_cards,
		"decision_card": {
			"title": last_card["title"],
			"description": last_card["description"],
			"choices": {
				"right": {
					"label": "View Survival Legend",
					"deltas": [0, 0, 0, 0, 0],
					"affected": []
				}
			}
		}
	}

	card_swiper.load_block_data(doom_block, 0)

func show_final_game_over_popup(result: Dictionary):
	var idx = result.get("failed_index", 0)
	var is_max = result.get("is_max", false)
	var ind_info = CardDatabase.INDICATORS.get(idx, {"name": "Resource"})
	var ind_name = ind_info.get("name", "Resource")

	var reason_text = ""
	if is_max:
		reason_text = "OVERFLOW DOOM! Your " + ind_name + " reached lethal capacity (100)!"
	else:
		reason_text = "DEPLETED DOOM! Your " + ind_name + " dropped to zero (0)!"

	var gold_earned = SaveManager.calculate_non_linear_gold(survival_points, hours_survived)
	SaveManager.add_gold(gold_earned)
	SaveManager.record_high_score(hours_survived, survival_points)

	game_over_reason.text = reason_text
	game_over_stats.text = "Hibernatus: " + SaveManager.current_save_data.get("player_name", "Hibernatus-09") + "\nSurvived: " + SaveManager.format_time_survived(hours_survived) + " (" + str(survival_points) + " Pts)"
	gold_earned_label.text = "💰 Converted to +" + str(gold_earned) + " Scrap Gold!"

	SaveManager.clear_save()
	game_over_modal.visible = true

func _on_shop_pressed():
	shop_modal.visible = true
	if shop_modal.has_method("update_shop_ui"):
		shop_modal.update_shop_ui()

func _on_shop_closed():
	update_time_and_points_label()

func _on_menu_pressed():
	update_equipment_modal_ui()
	pause_modal.visible = true

func _on_close_pause_pressed():
	pause_modal.visible = false
	update_time_and_points_label()

func update_equipment_modal_ui():
	for child in inventory_list.get_children():
		child.queue_free()

	var inv = SaveManager.current_save_data.get("inventory", [])
	var active_prots = SaveManager.current_save_data.get("active_protections", [])

	if inv.is_empty():
		var lbl = Label.new()
		lbl.text = "No bought protections in inventory. Visit the Shop to purchase shields!"
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.add_theme_font_size_override("font_size", 13)
		inventory_list.add_child(lbl)
		return

	for item_id in inv:
		var item_info = {}
		for s in CardDatabase.shop_items:
			if s["id"] == item_id:
				item_info = s
				break

		if item_info.is_empty() or item_info.get("category", "") != "protection":
			continue

		var card_panel = PanelContainer.new()
		var vbox = VBoxContainer.new()

		var name_lbl = Label.new()
		name_lbl.text = item_info["name"]
		name_lbl.add_theme_font_size_override("font_size", 14)
		name_lbl.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
		vbox.add_child(name_lbl)

		var is_equipped = false
		for p in active_prots:
			if p.get("id", "") == item_id:
				is_equipped = true
				break

		var equip_btn = Button.new()
		equip_btn.custom_minimum_size = Vector2(0, 36)

		if is_equipped:
			equip_btn.disabled = true
			equip_btn.text = "EQUIPPED (Active Shield)"
		else:
			var check = SaveManager.can_equip_protection(item_info.get("prot_type", "small"))
			if not check["can_equip"]:
				equip_btn.disabled = true
				equip_btn.text = check["reason"]
			else:
				equip_btn.disabled = false
				equip_btn.text = "INSTALL / EQUIP SHIELD"
				equip_btn.pressed.connect(func():
					var p_dict = {
						"id": item_id,
						"type": item_info.get("prot_type", "small"),
						"indicator": item_info.get("indicator", 0),
						"mode": item_info.get("mode", "min")
					}
					SaveManager.equip_protection(p_dict)
					top_panel.update_protection_shields()
					update_equipment_modal_ui()
				)

		vbox.add_child(equip_btn)
		card_panel.add_child(vbox)
		inventory_list.add_child(card_panel)

func _on_play_again_pressed():
	game_over_modal.visible = false
	SaveManager.start_new_game()
	init_game()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
