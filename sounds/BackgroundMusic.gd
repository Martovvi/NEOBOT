extends Node

onready var music1 = $Music1
onready var music2 = $Music2
onready var music3 = $Music3

func _on_Music1_finished():
	music2.play()

func _on_Music2_finished():
		music3.play()

func _on_Music3_finished():
	music1.play()

func _input(_event):
	if Input.is_action_pressed("next_track"):
		if(music1.is_playing()):
			music1.stop()
		if(music2.is_playing()):
			music2.stop()
		if(music3.is_playing()):
			music3.stop()
