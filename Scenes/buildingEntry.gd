extends Node3D

@onready var entry_area = $EntryArea
@onready var label = $Label3D
@export var scene_to_load: PackedScene
var player_in_area = false

func _ready():
	entry_area.connect("body_entered", _on_body_entered)
	entry_area.connect("body_exited", _on_body_exited)
	print("✅ BuildingEntry Loaded!")
	label.visible = false

func _on_body_entered(body):
	print("נכנס: ", body.name)
	if body.is_in_group("player"):
		print("זה השחקן!")
	if body.name == "Player":
		player_in_area = true
		label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		label.visible = false

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		if scene_to_load:
			get_tree().change_scene_to_packed(scene_to_load)


func _on_entry_area_body_entered(_body: Node3D) -> void:
	print("נכנס שחקן:", _body.name)
	pass # Replace with function body.
