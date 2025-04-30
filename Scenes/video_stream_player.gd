extends VideoStreamPlayer

# נתיב למסך הבא שייפתח אחרי שהסרטון מסתיים
@export var next_scene_path: String = "res://Scenes/character_selection2.tscn"

func _ready():
	connect("finished", Callable(self, "_on_video_finished"))

func _on_video_finished():
	get_tree().change_scene_to_file(next_scene_path)

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # מקש ברירת מחדל עבור ESC
		stop()
		_on_video_finished()
