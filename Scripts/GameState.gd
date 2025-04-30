extends Node

var selected_character: Variant = null
var selected_name: String = ""
var selected_name_eng: String = ""
var puzzles_completed := 0
var selected_image_path := ""
var mini_games_results := {}

var inventory: Array[String] = []


func add_item(item_name: String) -> void:
	if not inventory.has(item_name):
		inventory.append(item_name)
		print("נוסף לפריטים: ", item_name)
	else:
		print("הפריט כבר קיים: ", item_name)


func has_item(item_name: String) -> bool:
	return inventory.has(item_name)
