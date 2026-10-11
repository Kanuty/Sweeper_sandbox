extends Control

signal swipe_committed(direction, choice_data)
signal drag_updated(direction, choice_data)
signal drag_ended()

const SWIPE_THRESHOLD = 80.0
const ROTATION_FACTOR = 0.0008

@onready var card_panel = $CardPanel
@onready var card_title = $CardPanel/VBoxContainer/TitleLabel
@onready var card_desc = $CardPanel/VBoxContainer/DescLabel
@onready var choice_overlay = $CardPanel/ChoiceOverlay

# PC Side / Directional Buttons
@onready var btn_left = $PCControls/BtnLeft
@onready var btn_right = $PCControls/BtnRight
@onready var btn_up = $PCControls/BtnUp
@onready var btn_down = $PCControls/BtnDown

var current_card_data = {}
var is_dragging = false
var drag_start_pos = Vector2.ZERO
var initial_card_pos = Vector2.ZERO
var current_direction = ""

func _ready():
	# Store initial centered layout position
	initial_card_pos = card_panel.position

	# Connect PC click buttons
	btn_left.pressed.connect(func(): commit_choice("left"))
	btn_right.pressed.connect(func(): commit_choice("right"))
	btn_up.pressed.connect(func(): commit_choice("up"))
	btn_down.pressed.connect(func(): commit_choice("down"))

func set_card_data(data: Dictionary):
	current_card_data = data
	card_title.text = data.get("title", "")
	card_desc.text = data.get("description", "")
	reset_card_position()

func reset_card_position():
	card_panel.position = initial_card_pos
	card_panel.rotation = 0.0
	choice_overlay.text = ""
	current_direction = ""
	emit_signal("drag_ended")

func _gui_input(event):
	if current_card_data.is_empty():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_pos = event.position
			else:
				if is_dragging:
					is_dragging = false
					finish_drag()

	elif event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			drag_start_pos = event.position
		else:
			if is_dragging:
				is_dragging = false
				finish_drag()

	elif event is InputEventMouseMotion and is_dragging:
		var offset = event.position - drag_start_pos
		update_drag_position(offset)

	elif event is InputEventScreenDrag and is_dragging:
		var offset = event.position - drag_start_pos
		update_drag_position(offset)

func _unhandled_input(event):
	if current_card_data.is_empty():
		return

	# Keyboard Arrow support
	if event.is_action_pressed("ui_left"):
		commit_choice("left")
	elif event.is_action_pressed("ui_right"):
		commit_choice("right")
	elif event.is_action_pressed("ui_up"):
		commit_choice("up")
	elif event.is_action_pressed("ui_down"):
		commit_choice("down")

func update_drag_position(offset: Vector2):
	card_panel.position = initial_card_pos + offset
	card_panel.rotation = offset.x * ROTATION_FACTOR

	# Determine primary swipe direction
	if offset.length() < 20.0:
		current_direction = ""
		choice_overlay.text = ""
		emit_signal("drag_ended")
		return

	if abs(offset.x) > abs(offset.y):
		current_direction = "right" if offset.x > 0 else "left"
	else:
		current_direction = "down" if offset.y > 0 else "up"

	var choices = current_card_data.get("choices", {})
	if choices.has(current_direction):
		var choice = choices[current_direction]
		choice_overlay.text = choice.get("label", "").to_upper()
		emit_signal("drag_updated", current_direction, choice)

func finish_drag():
	var offset = card_panel.position - initial_card_pos
	if offset.length() >= SWIPE_THRESHOLD and current_direction != "":
		commit_choice(current_direction)
	else:
		# Snap back to initial centered position
		var tween = create_tween().set_parallel(true)
		tween.tween_property(card_panel, "position", initial_card_pos, 0.2).set_trans(Tween.TRANS_SPRING)
		tween.tween_property(card_panel, "rotation", 0.0, 0.2)
		choice_overlay.text = ""
		current_direction = ""
		emit_signal("drag_ended")

func commit_choice(direction: String):
	var choices = current_card_data.get("choices", {})
	if choices.has(direction):
		var choice = choices[direction]

		# Animate card flick off-screen relative to initial position
		var target_pos = initial_card_pos
		match direction:
			"left": target_pos = Vector2(-600, card_panel.position.y)
			"right": target_pos = Vector2(600, card_panel.position.y)
			"up": target_pos = Vector2(card_panel.position.x, -800)
			"down": target_pos = Vector2(card_panel.position.x, 800)

		var tween = create_tween()
		tween.tween_property(card_panel, "position", target_pos, 0.25).set_trans(Tween.TRANS_QUAD)
		tween.tween_callback(func():
			reset_card_position()
			emit_signal("swipe_committed", direction, choice)
		)
