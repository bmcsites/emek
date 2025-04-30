extends CanvasLayer

@export var dialogue_file_path: String = "" # ריק כברירת מחדל
@export var start_node: String = "start"

@onready var dialog_label = $DialogBox/DialogText
@onready var character_name_label = $DialogBox/CharacterName
@onready var options_container = $DialogBox/OptionsContainer

var dialogue_data: Dictionary = {}
var current_node: String = ""
var waiting_for_choice: bool = false

func _ready():
	# לא מתחילים דיאלוג אוטומטית יותר!
	pass

func set_dialogue(path: String, start_id: String = "start") -> void:
	dialogue_file_path = path
	start_node = start_id
	load_dialogue_file(dialogue_file_path)
	start_dialogue(start_node)

func load_dialogue_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var result = JSON.parse_string(text)
		if result != null:
			dialogue_data = result
		else:
			push_error("Failed to parse JSON at path: %s" % path)
	else:
		push_error("Failed to open file: %s" % path)

func start_dialogue(start_id: String):
	current_node = start_id
	show_dialog(current_node)

func _input(event):
	if event.is_action_pressed("ui_accept") and not waiting_for_choice:
		proceed_dialog()

func proceed_dialog():
	var node = dialogue_data.get(current_node, {})
	if node.has("choices"):
		waiting_for_choice = true
		show_choices(node["choices"])
	elif node.has("next"):
		current_node = node["next"]
		show_dialog(current_node)
	elif node.has("action"):
		handle_action(node["action"])

func show_dialog(key: String):
	var node = dialogue_data.get(key, {})
	current_node = key

	var text: String = node.get("text", "")
	text = apply_text_variables(text)

	dialog_label.text = text
	character_name_label.text = node.get("character", "")
	options_container.hide()
	waiting_for_choice = false

func show_choices(choices: Array):
	options_container.show()
	for child in options_container.get_children():
		child.queue_free()

	for choice in choices:
		# תנאי: requires_item
		if choice.has("requires_item"):
			var required_item = choice["requires_item"]
			if not GameState.has_item(required_item):
				continue

		# תנאי: requires_character
		if choice.has("requires_character"):
			var required_name = choice["requires_character"]
			if GameState.selected_name != required_name:
				continue

		var btn = Button.new()
		btn.text = choice["text"]

		# בדיקה אם next מוביל ל-give_item שכבר קיבלנו
		if choice.has("next"):
			var next_node = dialogue_data.get(choice["next"], {})
			if next_node.has("action"):
				var action = next_node["action"]
				if action.get("type", "") == "give_item":
					var item_name = action.get("item", "")
					if GameState.has_item(item_name):
						btn.disabled = true

		btn.connect("pressed", Callable(self, "_on_choice_selected").bind(choice["next"]))
		options_container.add_child(btn)

func _on_choice_selected(next_key: String):
	waiting_for_choice = false
	current_node = next_key
	show_dialog(current_node)

func handle_action(action: Dictionary):
	match action.get("type", ""):
		"give_item":
			var item_name = action.get("item", "")
			if item_name != "":
				GameState.add_item(item_name)
			if action.has("next"):
				current_node = action["next"]
				show_dialog(current_node)

		"change_scene":
			var scene_path = action.get("scene", "")
			if scene_path != "":
				get_tree().change_scene_to_file(scene_path)

func apply_text_variables(text: String) -> String:
	return text.replace("{player_name}", GameState.selected_name)
