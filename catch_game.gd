extends Node2D

var game_name = 'catch-game'
var score: int = 0
var time_left: float = 60.0
var game_ended: bool = false
var character = GameState.selected_name_eng

@onready var score_label = $ScoreLabel
@onready var timer_label = $TimerLabel
@onready var game_timer = $GameTimer
@onready var spawn_timer = $SpawnTimer
@onready var message_label = $UIOverlay/MessageLabel
@onready var retry_button = $UIOverlay/RetryButton
@onready var exit_button = $UIOverlay/ExitButton
@onready var bg = $UIOverlay/bg
@onready var player = $Player

func _ready() -> void:
	reset_game()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"): # ברירת מחדל ל-ESC
		force_game_over()
		return
	if not game_ended:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			update_timer_label()
			end_game()
		else:
			update_timer_label()

func _on_spawn_timer_timeout() -> void:
	if game_ended:
		return

	var item_scene = load("res://Scenes/rooms/games/catch_game-items.tscn")
	var item = item_scene.instantiate()

	var items_list = ["pin1", "bang", "ashtray", "bottle", "rizla"]
	item.item_name = items_list.pick_random()

	var screen_size = get_viewport_rect().size
	item.position = Vector2(randi() % int(screen_size.x), -50)

	add_child(item)

	item.connect("caught", Callable(self, "_on_item_caught"))

func _on_item_caught(caught_by: Node) -> void:
	if caught_by != null:
		add_score(1)
		$CatchSound.play()
	else:
		add_score(-1)

func add_score(amount: int) -> void:
	score += amount
	if score < 0:
		score = 0
	update_score_label()

func update_score_label() -> void:
	score_label.text = "נקודות: %d" % score

func update_timer_label() -> void:
	timer_label.text = "זמן שנשאר: %d שניות" % int(time_left)

func end_game() -> void:
	if game_ended:
		return
	game_ended = true

	spawn_timer.stop()
	game_timer.stop()

	# 🔥 נועלים את הדמות
	player.set_process(false)

	# 🔥 מוחקים את כל החפצים על המסך
	for child in get_children():
		if child.name == "Item": # אם החפץ הוא מסוג Item
			child.queue_free()

	save_mini_game_result()

	if score >= 20:
		show_win_screen()
	else:
		show_lose_screen()

func save_mini_game_result() -> void:
	# אם אין רשומה לדמות הזאת בכלל, ניצור מילון חדש
	if not GameState.mini_games_results.has(character):
		GameState.mini_games_results[character] = {}
	
	# אם אין מילון למשחק הספציפי, ניצור גם אותו
	if not GameState.mini_games_results[character].has(game_name):
		GameState.mini_games_results[character][game_name] = {}
	
	# עכשיו אפשר לשמור בוודאות
	GameState.mini_games_results[character][game_name]["score"] = score
	GameState.mini_games_results[character][game_name]["completed"] = score >= 20

func show_win_screen() -> void:
	message_label.text = "🎉 ניצחת!"
	retry_button.show()
	exit_button.show()
	bg.show()

func show_lose_screen() -> void:
	message_label.text = "❌ הפסדת!"
	retry_button.show()
	exit_button.show()
	bg.show()

func _on_retry_button_pressed() -> void:
	reset_game()

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func force_game_over() -> void:
	if time_left > 0:
		time_left = 0
		game_timer.stop()
		spawn_timer.stop()
		player.set_process(false)
		game_ended = true # הוספנו כאן
		for child in get_children():
			if child.name == "Item":
				child.queue_free()
		show_lose_screen()


func reset_game() -> void:
	score = 0
	time_left = 60
	game_ended = false
	update_score_label()
	update_timer_label()

	message_label.text = ""
	retry_button.hide()
	exit_button.hide()
	bg.hide()

	game_timer.start()
	spawn_timer.start()

	# 🔥 משחררים את הדמות חזרה לפעולה
	player.set_process(true)

	# 🔥 מוחקים חפצים ישנים אם נשארו
	for child in get_children():
		if child.name == "Item":
			child.queue_free()
