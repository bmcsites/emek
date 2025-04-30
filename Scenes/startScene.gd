extends Node2D

@onready var music_player = $MusicPlayer
@onready var lyrics_label = $LyricsLabel

var lyrics = []
var current_index = 0

func _ready():
	load_lyrics("res://Assets/start/lyrics.json")
	music_player.play()
	current_index = 0
	lyrics_label.text = ""
	set_process(true)

func load_lyrics(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	lyrics = JSON.parse_string(text)

func _process(delta):
	if current_index >= lyrics.size():
		return
	
	var current_time = music_player.get_playback_position()
	var next_lyric = lyrics[current_index]
	
	if current_time >= next_lyric["time"]:
		lyrics_label.text = next_lyric["text"]
		current_index += 1


func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/introMovie.tscn")
