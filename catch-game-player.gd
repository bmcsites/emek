extends CharacterBody2D

@export var move_speed: float = 400.0
@export var jump_force: float = 600.0
@export var gravity: float = 1000.0

@onready var sprite = $Sprite2D

var normal_texture: Texture
var jump_texture: Texture
var is_jumping: bool = false

func _ready() -> void:
	load_player_sprites()

func load_player_sprites() -> void:
	if GameState.selected_name_eng != "":
		var player_name = GameState.selected_name_eng
		var normal_path = "res://Assets/characters/mini-game/%s-mini-game.png" % player_name
		var jump_path = "res://Assets/characters/mini-game/%s-jumpi-mini-game.png" % player_name
		
		normal_texture = load(normal_path)
		jump_texture = load(jump_path)
		
		if normal_texture:
			sprite.texture = normal_texture
		else:
			print("❌ לא נמצאה תמונת עמידה: " + normal_path)

		if not jump_texture:
			print("❌ לא נמצאה תמונת קפיצה: " + jump_path)

func _physics_process(_delta: float) -> void:
	handle_input()
	apply_gravity()
	move_and_update_sprite()
	update_sprite_texture()

func handle_input() -> void:
	velocity.x = 0

	if Input.is_action_pressed("ui_right"):
		velocity.x = move_speed
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -move_speed
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -jump_force
		$JumpSound.play()

func apply_gravity() -> void:
	if not is_on_floor():
		velocity.y += gravity * get_physics_process_delta_time()

func move_and_update_sprite() -> void:
	move_and_slide()

	if velocity.x > 0:
		sprite.scale.x = -1
	elif velocity.x < 0:
		sprite.scale.x = 1

func update_sprite_texture() -> void:
	if not is_on_floor():
		if not is_jumping:
			is_jumping = true
			if jump_texture:
				sprite.texture = jump_texture
	else:
		if is_jumping:
			is_jumping = false
			if normal_texture:
				sprite.texture = normal_texture
