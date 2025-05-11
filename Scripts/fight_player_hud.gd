extends MarginContainer

@onready var health_bar = $HBoxContainer/VBoxContainer/MarginContainer/ProgressBar
@onready var name_label = $HBoxContainer/VBoxContainer/name_label
@onready var portrait_image = $HBoxContainer/HUDImageContainer

func setup(name_eng: String, is_eng_side: bool) -> void:
	var suffix := "_hud.png"
	if not is_eng_side:
		suffix = "_eng_hud.png"

	var image_path := "res://Assets/hud/%s%s" % [name_eng, suffix]
	if name_eng == 'poti':
		name_label.text = 'פותי'
	if name_eng == 'matos':
		name_label.text = 'מטוס'
	if name_eng == 'tziki':
		name_label.text = 'ציקי'

	if FileAccess.file_exists(image_path):
		var texture = load(image_path)
		if texture:
			portrait_image.texture = texture

	$HBoxContainer.set("layout_direction", HBoxContainer.LAYOUT_DIRECTION_RTL if is_eng_side else HBoxContainer.LAYOUT_DIRECTION_LTR)
	health_bar.value = 100

func set_health(value: float):
	health_bar.value = clamp(value, 0, 100)
