extends CanvasLayer

var selected_character: TextureButton = null
var selected_name: String = ""

@onready var poti = $SelectedPreview/poti
@onready var matos = $SelectedPreview/matos
@onready var tziki = $SelectedPreview/tziki
@onready var name_label = $SelectedPreview/name_label
@onready var start_button = $SelectedPreview/start_button
@onready var sound_player = $character_sound_player

func _ready():
	# טוען טקסטורות לכל הדמויות
	set_character_textures(poti, "poti")
	set_character_textures(matos, "matos")
	set_character_textures(tziki, "tziki")

	# מחבר לחיצות
	poti.pressed.connect(func(): _select_character(poti, "poti", "פוטי"))
	matos.pressed.connect(func(): _select_character(matos, "matos", "מטוס"))
	tziki.pressed.connect(func(): _select_character(tziki, "tziki", "ציקי"))

	# הכפתור כבוי עד שיבחרו דמות
	start_button.disabled = true
	start_button.pressed.connect(_on_start_pressed)
	name_label.text = "בחר שחקן"

func set_character_textures(button: TextureButton, char_id: String):
	button.texture_normal = load("res://Assets/Character_selection/%s1.png" % char_id)
	button.texture_hover = load("res://Assets/Character_selection/%s2.png" % char_id)
	button.texture_pressed = null

func _select_character(new_selection: TextureButton, char_id: String, hebrew_name: String):
	if selected_character != null:
		var previous_name = selected_character.name
		selected_character.texture_normal = load("res://Assets/Character_selection/%s1.png" % previous_name)
		selected_character.texture_hover = load("res://Assets/Character_selection/%s2.png" % previous_name)

	new_selection.texture_normal = load("res://Assets/Character_selection/%s3.png" % char_id)
	new_selection.texture_hover = load("res://Assets/Character_selection/%s3.png" % char_id)

	selected_character = new_selection
	selected_character.name = char_id
	selected_name = hebrew_name

	name_label.text = "%s" % hebrew_name
	start_button.disabled = false

	# 🎵 ניגון הסאונד של הדמות
	var sound_path = "res://Assets/Sounds/%s_sound.wav" % char_id
	sound_player.stream = load(sound_path)
	sound_player.play()

	# ✅ שמירת מידע ב-GameState
	GameState.selected_name = hebrew_name
	GameState.selected_name_eng = char_id
	GameState.selected_character = selected_character
	GameState.selected_image_path = "res://Assets/hud/%s.png" % char_id  # ⬅️ כאן שמור את התמונה הקטנה להצגה ב־HUD
func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
