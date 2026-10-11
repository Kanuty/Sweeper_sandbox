extends Node

const SAVE_PATH = "user://savegame.json"

var current_save_data = {
	"has_active_game": false,
	"days_survived": 0,
	"indicators": [50.0, 50.0, 50.0, 50.0], # 0: People, 1: Treasury, 2: Environment, 3: Tech
	"used_card_ids": [],
	"active_card_id": "",
	"protection_active": false
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
		"days_survived": 0,
		"indicators": default_indicators.duplicate(),
		"used_card_ids": [],
		"active_card_id": "",
		"protection_active": false
	}
	save_game()

func clear_save():
	current_save_data = {
		"has_active_game": false,
		"days_survived": 0,
		"indicators": [50.0, 50.0, 50.0, 50.0],
		"used_card_ids": [],
		"active_card_id": "",
		"protection_active": false
	}
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	save_game()
