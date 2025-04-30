
extends CharacterBody3D

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var collider: CollisionShape3D = $Collider

@export var can_move : bool = true
@export var has_gravity : bool = true
@export var can_jump : bool = true

@export var look_speed : float = 0.002
@export var base_speed : float = 7.0
@export var jump_velocity : float = 4.5

@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_forward : String = "ui_up"
@export var input_back : String = "ui_down"
@export var input_jump : String = "ui_accept"

var is_rotating_with_mouse := false
var is_look_only := false
var is_resetting_head := false

var reset_speed := 10.0 # higher = faster snap back

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print(GameState.selected_character)
	print(GameState.selected_name)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_rotating_with_mouse = event.pressed
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_look_only = event.pressed
			if not event.pressed:
				is_resetting_head = true

	if event is InputEventMouseMotion:
		if is_rotating_with_mouse:
			rotate_y(-event.relative.x * look_speed)
			head.rotate_x(-event.relative.y * look_speed)
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		elif is_look_only:
			head.rotate_y(-event.relative.x * look_speed)
			head.rotate_x(-event.relative.y * look_speed)
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	var input_dir = Vector3.ZERO

	if Input.is_action_pressed(input_forward):
		input_dir -= transform.basis.z
	if Input.is_action_pressed(input_back):
		input_dir += transform.basis.z

	# Rotate character with A/D instead of strafing
	if Input.is_action_pressed(input_left):
		rotate_y(look_speed * 10)
	if Input.is_action_pressed(input_right):
		rotate_y(-look_speed * 10)

	input_dir.y = 0
	input_dir = input_dir.normalized()

	if can_move:
		velocity.x = input_dir.x * base_speed
		velocity.z = input_dir.z * base_speed

	if has_gravity:
		if not is_on_floor():
			velocity.y -= 9.8 * delta
		else:
			if Input.is_action_just_pressed(input_jump) and can_jump:
				velocity.y = jump_velocity

	move_and_slide()

	if is_resetting_head:
		var current_rot = head.rotation
		var target_rot = Vector3(current_rot.x, 0, 0)
		head.rotation = head.rotation.lerp(target_rot, reset_speed * delta)

		if abs(head.rotation.y) < 0.01:
			head.rotation.y = 0
			is_resetting_head = false
