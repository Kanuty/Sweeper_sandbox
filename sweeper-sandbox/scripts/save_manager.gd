extends Node

const SAVE_PATH = "user://savegame.json"

var current_save_data = {
	"has_active_game": false,
	"hours_survived": 0,
	"survival_points": 0,
	"indicators": [50.0, 50.0, 50.0, 50.0],
	"used_block_ids": [],
	"active_block_id": "",
	"active_card_index": 0,
	"gold_coins": 100, # Persistent Gold currency
	"inventory": [], # Array of purchased item IDs: ["prot_small_people_min", "item_exact_insight", ...]
	"active_protections": [], # Array of dicts: [{"id": "...", "type": "small"/"big", "indicator": 0, "mode": "min"/"max"/"both"}]
	"active_modifier": "", # Insight modifier
	"modifier_block_charges": 0,
	"install_cooldown": 0 # Decisions remaining until next protection can be installed
}

func _ready():
	load_game()

func has_save() -> bool:
	return current_save_data.get("has_active_game", false)

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(current_save_data)
		file.store_string(json_string)
		file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			if typeof(data) == TYPE_DICTIONARY:
				current_save_data = data
				if not current_save_data.has("gold_coins"):
					current_save_data["gold_coins"] = 100
				if not current_save_data.has("survival_points"):
					current_save_data["survival_points"] = 0
				if not current_save_data.has("inventory"):
					current_save_data["inventory"] = []
				if not current_save_data.has("active_protections"):
					current_save_data["active_protections"] = []
				if not current_save_data.has("install_cooldown"):
					current_save_data["install_cooldown"] = 0

func start_new_game(default_indicators = [50.0, 50.0, 50.0, 50.0]):
	var current_gold = current_save_data.get("gold_coins", 100)
	var inv = current_save_data.get("inventory", []).duplicate()
	var active_mod = current_save_data.get("active_modifier", "")
	var charges = current_save_data.get("modifier_block_charges", 0)

	current_save_data = {
		"has_active_game": true,
		"hours_survived": 0,
		"survival_points": 0,
		"indicators": default_indicators.duplicate(),
		"used_block_ids": [],
		"active_block_id": "",
		"active_card_index": 0,
		"gold_coins": current_gold,
		"inventory": inv,
		"active_protections": [],
		"active_modifier": active_mod,
		"modifier_block_charges": charges,
		"install_cooldown": 0
	}
	save_game()

func add_gold(amount: int):
	var gold = current_save_data.get("gold_coins", 0)
	gold += amount
	current_save_data["gold_coins"] = gold
	save_game()

func add_survival_points(pts: int):
	var points = current_save_data.get("survival_points", 0)
	points += pts
	current_save_data["survival_points"] = points
	save_game()

func calculate_non_linear_gold(pts: int, hours: int) -> int:
	var days = hours / 24
	var multiplier = 1.0 + (days * 0.15) + ((days * days) * 0.05)
	var gold_reward = int(round(pts * multiplier)) + (days * 15)
	return max(15, gold_reward)

func set_modifier(mod_type: String, charges: int = 0):
	current_save_data["active_modifier"] = mod_type
	current_save_data["modifier_block_charges"] = charges
	save_game()

func consume_modifier_charge():
	var charges = current_save_data.get("modifier_block_charges", 0)
	if charges > 0:
		charges -= 1
		current_save_data["modifier_block_charges"] = charges
		if charges <= 0:
			var mod = current_save_data.get("active_modifier", "")
			if mod.begins_with("timed_"):
				current_save_data["active_modifier"] = ""

	var cooldown = current_save_data.get("install_cooldown", 0)
	if cooldown > 0:
		cooldown -= 1
		current_save_data["install_cooldown"] = cooldown

	save_game()

func add_to_inventory(item_id: String):
	var inv = current_save_data.get("inventory", [])
	if not item_id in inv:
		inv.append(item_id)
		current_save_data["inventory"] = inv
		save_game()

func can_equip_protection(prot_type: String) -> Dictionary:
	var cooldown = current_save_data.get("install_cooldown", 0)
	if cooldown > 0:
		return {"can_equip": false, "reason": "Install Cooldown: Wait " + str(cooldown) + " more decision(s)."}

	var active_prots = current_save_data.get("active_protections", [])
	var small_count = 0
	var big_count = 0
	for p in active_prots:
		if p.get("type", "") == "small":
			small_count += 1
		elif p.get("type", "") == "big":
			big_count += 1

	if prot_type == "small":
		if big_count > 0:
			return {"can_equip": false, "reason": "1 Big Protection is active (cannot mix with Small)."}
		if small_count >= 2:
			return {"can_equip": false, "reason": "Maximum 2 Small Protections already active."}
	elif prot_type == "big":
		if small_count > 0 or big_count >= 1:
			return {"can_equip": false, "reason": "Maximum 1 Big Protection active (cannot mix with Small)."}

	return {"can_equip": true, "reason": ""}

func equip_protection(prot_dict: Dictionary):
	var active_prots = current_save_data.get("active_protections", [])
	active_prots.append(prot_dict)
	current_save_data["active_protections"] = active_prots
	save_game()

func remove_protection_and_set_cooldown(index: int, cooldown_decisions: int):
	var active_prots = current_save_data.get("active_protections", [])
	if index >= 0 and index < active_prots.size():
		active_prots.remove_at(index)
		current_save_data["active_protections"] = active_prots
		current_save_data["install_cooldown"] = cooldown_decisions
		save_game()

func clear_save():
	var gold = current_save_data.get("gold_coins", 100)
	var inv = current_save_data.get("inventory", [])
	var active_mod = current_save_data.get("active_modifier", "")
	var charges = current_save_data.get("modifier_block_charges", 0)

	current_save_data = {
		"has_active_game": false,
		"hours_survived": 0,
		"survival_points": 0,
		"indicators": [50.0, 50.0, 50.0, 50.0],
		"used_block_ids": [],
		"active_block_id": "",
		"active_card_index": 0,
		"gold_coins": gold,
		"inventory": inv,
		"active_protections": [],
		"active_modifier": active_mod,
		"modifier_block_charges": charges,
		"install_cooldown": 0
	}
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	save_game()

func format_time_survived(hours: int) -> String:
	var days = hours / 24
	var rem_hours = hours % 24
	if days == 0:
		return str(rem_hours) + " Hours"
	elif rem_hours == 0:
		return str(days) + " Days"
	else:
		return str(days) + " Days, " + str(rem_hours) + " Hours"
