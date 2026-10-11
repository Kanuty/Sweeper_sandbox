extends Node

const SAVE_PATH = "user://savegame.json"

var current_save_data = {
	"has_active_game": false,
	"hours_survived": 0,
	"indicators": [50.0, 50.0, 50.0, 50.0],
	"used_block_ids": [],
	"active_block_id": "",
	"active_card_index": 0,
	"gold_coins": 100, # Starting bonus gold balance persistent across sessions
	"active_modifier": "", # "", "exact_insight", "small_insight", "timed_exact_insight", "timed_small_insight"
	"modifier_block_charges": 0
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
				# Ensure default keys exist if missing from older saves
				if not current_save_data.has("gold_coins"):
					current_save_data["gold_coins"] = 100
				if not current_save_data.has("active_modifier"):
					current_save_data["active_modifier"] = ""
				if not current_save_data.has("modifier_block_charges"):
					current_save_data["modifier_block_charges"] = 0

func start_new_game(default_indicators = [50.0, 50.0, 50.0, 50.0]):
	# Maintain persistent gold and active modifiers across runs
	var current_gold = current_save_data.get("gold_coins", 100)
	var active_mod = current_save_data.get("active_modifier", "")
	var charges = current_save_data.get("modifier_block_charges", 0)

	current_save_data = {
		"has_active_game": true,
		"hours_survived": 0,
		"indicators": default_indicators.duplicate(),
		"used_block_ids": [],
		"active_block_id": "",
		"active_card_index": 0,
		"gold_coins": current_gold,
		"active_modifier": active_mod,
		"modifier_block_charges": charges
	}
	save_game()

func add_gold(amount: int):
	var gold = current_save_data.get("gold_coins", 0)
	gold += amount
	current_save_data["gold_coins"] = gold
	save_game()

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
		save_game()

func clear_save():
	var gold = current_save_data.get("gold_coins", 100)
	var active_mod = current_save_data.get("active_modifier", "")
	var charges = current_save_data.get("modifier_block_charges", 0)

	current_save_data = {
		"has_active_game": false,
		"hours_survived": 0,
		"indicators": [50.0, 50.0, 50.0, 50.0],
		"used_block_ids": [],
		"active_block_id": "",
		"active_card_index": 0,
		"gold_coins": gold,
		"active_modifier": active_mod,
		"modifier_block_charges": charges
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
