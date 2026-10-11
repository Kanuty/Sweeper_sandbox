extends Node

const SAVE_PATH = "user://savegame.json"

var current_save_data = {
	"has_active_game": false,
	"hours_survived": 0,
	"indicators": [50.0, 50.0, 50.0, 50.0],
	"used_block_ids": [],
	"active_block_id": "",
	"active_card_index": 0
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

func start_new_game(default_indicators = [50.0, 50.0, 50.0, 50.0]):
	current_save_data = {
		"has_active_game": true,
		"hours_survived": 0,
		"indicators": default_indicators.duplicate(),
		"used_block_ids": [],
		"active_block_id": "",
		"active_card_index": 0
	}
	save_game()

func clear_save():
	current_save_data = {
		"has_active_game": false,
		"hours_survived": 0,
		"indicators": [50.0, 50.0, 50.0, 50.0],
		"used_block_ids": [],
		"active_block_id": "",
		"active_card_index": 0
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
