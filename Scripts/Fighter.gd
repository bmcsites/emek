extends Node2D

var _is_player_controlled := false
var sprite: AnimatedSprite2D
var _health_bar = null
var health := 100
var _opponent: Node2D = null
var move_direction := 0
var is_attacking := false
var jump_height := -50.0
var jump_duration := 0.8
var jump_pressed := false
var is_jumping := false
var can_move := true  # משתנה חדש לבקרת תנועה
var kick_sound: AudioStreamPlayer
var hit_sound: AudioStreamPlayer
var scream_sound: AudioStreamPlayer
var jumpkick_sound: AudioStreamPlayer
var ai_state := "idle"
var ai_timer := 0.0
var move_speed := 200.0  # מהירות תנועה

func _ready():
	sprite = $AnimatedSprite2D
	if not sprite:
		push_error("AnimatedSprite2D לא נמצא!")
		return

	await get_tree().process_frame  # מחכה מסגרת אחת כדי לוודא ש־sprite_frames נטען
	
	kick_sound = AudioStreamPlayer.new()
	kick_sound.stream = preload("res://Assets/Sounds/kick.mp3")
	add_child(kick_sound)

	hit_sound = AudioStreamPlayer.new()
	hit_sound.stream = preload("res://Assets/Sounds/hit.mp3")
	add_child(hit_sound)

	scream_sound = AudioStreamPlayer.new()
	scream_sound.stream = preload("res://Assets/Sounds/scream.mp3")
	add_child(scream_sound)
	
	jumpkick_sound = AudioStreamPlayer.new()
	jumpkick_sound.stream = preload("res://Assets/Sounds/kick.mp3")  # נניח שזה אותו הסאונד כמו kick
	add_child(jumpkick_sound)
	
	if not sprite.sprite_frames:
		push_error("SpriteFrames לא נטען עדיין!")
		return

	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	else:
		push_error("לא קיימת אנימציה בשם 'idle'!")

	# כאן אנחנו מתחברים לסיום האנימציה
	if sprite.sprite_frames:
		sprite.animation_finished.connect(_on_animation_finished)

	if _is_player_controlled:
		print("Player 1 מוכן (שחקן נשלט)")
	else:
		print("Player 2 מוכן (AI)")

	setup_hitbox()

func set_can_move(value: bool) -> void:
	can_move = value

func set_is_player_controlled(value: bool) -> void:
	_is_player_controlled = value

func is_player_controlled() -> bool:
	return _is_player_controlled

func set_health_bar(bar):
	_health_bar = bar

func set_opponent(opponent: Node2D) -> void:
	_opponent = opponent

func _process(delta):
	if not sprite or not sprite.sprite_frames:
		return

	if _opponent:
		sprite.flip_h = _opponent.global_position.x < global_position.x

	if _is_player_controlled:
		# שליטה של שחקן
		if not is_attacking and not is_jumping and can_move:
			if move_direction != 0:
				position.x += move_direction * move_speed * delta
				if sprite.animation != "run" or not sprite.is_playing():
					sprite.play("run")
			else:
				if sprite.animation != "idle" or not sprite.is_playing():
					sprite.play("idle")
	else:
		# שליטה של AI
		handle_ai(delta)


func _unhandled_input(event):
	if not _is_player_controlled or not (event is InputEventKey):
		return

	if event.pressed:
		match event.keycode:
			KEY_A:
				move_direction = -1
				if not is_attacking and not is_jumping and can_move:
					sprite.play("run")  # מפעיל מחדש את אנימציית הריצה
			KEY_D:
				move_direction = 1
				if not is_attacking and not is_jumping and can_move:
					sprite.play("run")  # מפעיל מחדש את אנימציית הריצה
			KEY_W:
				if not jump_pressed:
					jump_pressed = true
					if Input.is_key_pressed(KEY_A):
						jump_kick(-1)
					elif Input.is_key_pressed(KEY_D):
						jump_kick(1)
					else:
						jump_kick()
			KEY_SPACE:
				attack()
	else:  # מקש שוחרר
		if event.keycode in [KEY_A, KEY_D]:
			move_direction = 0
			if not is_attacking and not is_jumping:
				sprite.play("idle")
		elif event.keycode == KEY_W:
			jump_pressed = false

func setup_hitbox():
	var hitbox := $HitBox
	var shape := $HitBox/CollisionShape2D

	if not hitbox or not shape:
		push_error("HitBox או CollisionShape2D לא נמצאו!")
		return

	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(333 * 0.5, 371 * 0.7)  # בערך 100x185
	shape.shape = rect_shape

	# מיקום hitbox: מעט קדימה ולמטה
	hitbox.position = Vector2(333 * 0.5, 371 * 0.5)

func check_hit():
	if not _opponent:
		return

	var hitbox = $HitBox
	if not hitbox:
		return

	var overlaps = hitbox.get_overlapping_areas()
	for area in overlaps:
		if area.get_parent() == _opponent:
			print("🎯 פגיעה ביריב דרך אזור!")
			_opponent.take_damage(10)
			break 


func jump_kick(dir := 0):
	if is_attacking or is_jumping:
		return

	is_attacking = true
	is_jumping = true
	can_move = false

	var base_height := -80
	var base_distance := 50
	var jump_h := base_height
	var jump_d := base_distance

	if dir != 0:
		jump_h *= 1.5
		jump_d *= 2
		position.x += dir * jump_d

	var original_y = position.y
	var jump_y = clamp(original_y + jump_h, 100, original_y)
	position.y = jump_y

	if jumpkick_sound:
		jumpkick_sound.play()

	if sprite.sprite_frames.has_animation("jump_kick"):
		sprite.play("jump_kick")
		await get_tree().create_timer(0.1).timeout
		check_hit()
		await sprite.animation_finished
		sprite.stop()

	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", original_y, 0.4)
	await tween.finished

	is_attacking = false
	is_jumping = false
	can_move = true
	sprite.play("idle")


func attack():
	if is_attacking or is_jumping:
		return
	is_attacking = true
	can_move = false

	if sprite.sprite_frames.has_animation("kick"):
		kick_sound.play()
		sprite.play("kick")

	# מחכים קצת כדי לאפשר לאנימציה להתחיל ואז בודקים פגיעה
	await get_tree().create_timer(0.1).timeout
	check_hit()

func _on_animation_finished():
	# מגיב לאירוע סיום אנימציה
	if sprite.animation in ["kick", "jump_kick"] and is_attacking:
		is_attacking = false
		can_move = true  # מחזיר את היכולת לזוז
		if not is_jumping:
			sprite.play("idle")

func take_damage(amount):
	# הורדת חיים
	health = clamp(health - amount, 0, 100)
	print("🩸 חיים נוכחיים:", health)

	# סאונד פגיעה
	if hit_sound:
		hit_sound.play()

	# עדכון ה־ProgressBar
	if _health_bar:
		_health_bar.value = health
	else:
		print("❌ אין HealthBar מחובר לדמות!")

	# השמעת "Finish Him" פעם אחת בלבד אם מתחת ל-10 חיים
	if health <= 10 and not has_node("finish_played"):
		var finish_marker = Node.new()
		finish_marker.name = "finish_played"
		add_child(finish_marker)

		var finish_sound = AudioStreamPlayer.new()
		finish_sound.stream = preload("res://Assets/Sounds/finish-him.mp3")
		add_child(finish_sound)
		finish_sound.play()

	# השמעת צרחה ומוות
	if health <= 0:
		if not has_node("scream_played"):
			var scream_marker = Node.new()
			scream_marker.name = "scream_played"
			add_child(scream_marker)

			var scream_sound = AudioStreamPlayer.new()
			scream_sound.stream = preload("res://Assets/Sounds/scream.mp3")
			add_child(scream_sound)
			scream_sound.play()

		die()

func die():
	if sprite and sprite.animation != "death":
		sprite.play("death")
		set_process(false)

		await get_tree().create_timer(1.0).timeout

		var fatality_sound = AudioStreamPlayer.new()
		fatality_sound.stream = preload("res://Assets/Sounds/fatality.mp3")
		add_child(fatality_sound)
		fatality_sound.play()


func handle_ai(delta):
	if is_attacking or is_jumping or not can_move:
		return

	ai_timer -= delta
	if ai_timer > 0:
		return

	var distance = global_position.distance_to(_opponent.global_position)

	# בוחר מצב לפי מרחק ומצב בריאות
	if health < 20 and distance < 200:
		ai_state = "retreat"
	elif distance > 150:
		ai_state = "approach"
	elif randi() % 100 < 30:
		ai_state = "attack"
	else:
		ai_state = "idle"

	match ai_state:
		"idle":
			if sprite.animation != "idle" or not sprite.is_playing():
				sprite.play("idle")

		"approach":
			var dir = sign(_opponent.global_position.x - global_position.x)
			position.x += dir * move_speed * delta
			sprite.play("run")

		"retreat":
			var dir = sign(global_position.x - _opponent.global_position.x)
			position.x += dir * move_speed * delta
			sprite.play("run")

		"attack":
			if randi() % 100 < 60:
				attack()
			else:
				var dir = sign(_opponent.global_position.x - global_position.x)
				jump_kick(dir)

	# מוודא שלא יוצאים מהמסך
	var screen_width = get_viewport_rect().size.x
	position.x = clamp(position.x, 20, screen_width - 20)

	# טיימר עד לפעולה הבאה
	ai_timer = randf_range(0.4, 0.8)
