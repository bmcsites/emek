extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 5.0
@export var gravity := 9.8

func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("ui_w_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_s_down"):
		direction.z += 1
	if Input.is_action_pressed("ui_a_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_d_right"):
		direction.x += 1

	direction = direction.normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()
