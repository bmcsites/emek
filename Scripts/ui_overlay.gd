extends CanvasLayer

@onready var name_label = $MarginContainer/HBoxContainer/VBoxContainer/name_label
@onready var puzzles_label = $MarginContainer/HBoxContainer/VBoxContainer/puzzles_label
@onready var portrait_image = $MarginContainer/HBoxContainer/HUDimageContainer

func _ready():
	if GameState.selected_image_path != "":
		var texture = load(GameState.selected_image_path)
		if texture:
			portrait_image.texture = texture

	name_label.text = "דמות: %s" % GameState.selected_name
	
	var completed_count = count_completed_games()
	puzzles_label.text = "פאזלים: %d מתוך 15" % completed_count

func count_completed_games() -> int:
	var count = 0
	var character = GameState.selected_name
	
	if GameState.mini_games_results.has(character):
		for game_name in GameState.mini_games_results[character]:
			var game_data = GameState.mini_games_results[character][game_name]
			if typeof(game_data) == TYPE_DICTIONARY and game_data.get("completed", false):
				count += 1
				
	return count
