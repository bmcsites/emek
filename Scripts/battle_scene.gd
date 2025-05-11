extends Node2D

@onready var start_label: Label = $UI/StartLabel
@onready var start_audio: AudioStreamPlayer = $startEnd
@onready var player1_ui = $topUI/player1_UI
@onready var player2_ui = $topUI/player2_UI

func _ready():
	var all_names = ["tziki", "poti", "matos"]
	var player1_name = GameState.selected_name_eng
	var remaining = all_names.filter(func(n): return n != player1_name)
	var player2_name = remaining[randi() % remaining.size()]
	
	var player1_path = "res://Assets/characters/mini-game/fighter_%s.png" % player1_name
	var player2_path = "res://Assets/characters/mini-game/fighter_%s.png" % player2_name

	var frames1 = load_sprite_frames(player1_path)
	var frames2 = load_sprite_frames(player2_path)
	
	player1_ui.setup(player1_name, true)
	player2_ui.setup(player2_name, false)

	# 🧭 מיקום של שחקני ה-UI
	player1_ui.anchor_left = 1.0
	player1_ui.anchor_right = 1.0
	player1_ui.offset_right = -20
	player1_ui.offset_top = 20

	player2_ui.anchor_left = 0.0
	player2_ui.anchor_right = 0.0
	player2_ui.offset_left = 20
	player2_ui.offset_top = 20

	$Player1/AnimatedSprite2D.sprite_frames = frames1
	$Player2/AnimatedSprite2D.sprite_frames = frames2

	$Player1.set_is_player_controlled(true)
	$Player2.set_is_player_controlled(false)

	$Player1.set_health_bar(player1_ui.health_bar)
	$Player2.set_health_bar(player2_ui.health_bar)

	$Player1.set_opponent($Player2)
	$Player2.set_opponent($Player1)

	# ❄️ מקפיא תנועה זמנית
	$Player1.set_can_move(false)
	$Player2.set_can_move(false)

	# ▶️ מציג כותרת עם שמות השחקנים
	start_label.visible = true
	start_label.text = "%s VS %s" % [player1_name.capitalize(), player2_name.capitalize()]

	await get_tree().create_timer(3.0).timeout

	start_label.text = "First Round!\nFight"
	start_audio.stream = preload("res://Assets/Sounds/round1-fight.mp3")
	start_audio.play()

	await get_tree().create_timer(3.0).timeout

	start_label.visible = false
	$Player1.set_can_move(true)
	$Player2.set_can_move(true)


func load_sprite_frames(path: String) -> SpriteFrames:
	var tex := load(path)
	var frames := SpriteFrames.new()
	var frame_size = Vector2i(333, 371)
	var columns = 3
	var animations = ["idle", "run", "kick", "jump_kick", "death"]

	for row in range(animations.size()):
		var anim_name = animations[row]
		frames.add_animation(anim_name)

		if anim_name == "run":
			frames.set_animation_speed(anim_name, 8)
			frames.set_animation_loop(anim_name, true)
		else:
			frames.set_animation_speed(anim_name, 6)

		if anim_name == "idle":
			frames.set_animation_loop(anim_name, true)
			var idle_region = Rect2(0, row * frame_size.y, frame_size.x, frame_size.y)
			var idle_atlas = AtlasTexture.new()
			idle_atlas.atlas = tex
			idle_atlas.region = idle_region
			frames.add_frame("idle", idle_atlas)
			continue

		if anim_name != "run":
			frames.set_animation_loop(anim_name, false)

		for col in range(1, columns):
			var region = Rect2(col * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y)
			var atlas = AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = region
			frames.add_frame(anim_name, atlas)

	return frames
