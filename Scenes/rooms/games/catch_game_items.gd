extends Area2D

signal caught(player)

@export var item_name: String = ""
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	if item_name != "":
		var sprite_path = "res://Assets/items/%s-game-asset.png" % item_name
		var texture = load(sprite_path)
		if texture:
			sprite.texture = texture
			create_collision_shape(texture.get_size())
		else:
			print("❌ לא נמצא קובץ לחפץ: " + sprite_path)

func create_collision_shape(size: Vector2) -> void:
	var shape = RectangleShape2D.new()
	shape.size = size
	collision_shape.shape = shape

func _physics_process(delta: float) -> void:
	position.y += 150 * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		emit_signal("caught", body) # שולח סיגנל
		queue_free()
	elif body.is_in_group("Ground"):
		emit_signal("caught", null) # אם פוגע בקרקע - שולח אבל בלי שחקן
		queue_free()
